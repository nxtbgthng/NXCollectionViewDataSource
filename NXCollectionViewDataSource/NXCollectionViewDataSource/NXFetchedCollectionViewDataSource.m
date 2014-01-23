//
//  NXFetchedCollectionViewDataSource.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXFetchedCollectionViewDataSource.h"

@interface NXFetchedCollectionViewDataSource () <NSFetchedResultsControllerDelegate>
#pragma mark Core Data Properties
@property (nonatomic, readwrite, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, readwrite, strong) NSString *sectionKeyPath;
@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;

#pragma mark Data Source Changes
@property (nonatomic, readonly) NSMutableIndexSet *insertedSections;
@property (nonatomic, readonly) NSMutableIndexSet *deletedSections;
@property (nonatomic, readonly) NSMutableArray *insertedItems;
@property (nonatomic, readonly) NSMutableArray *deletedItems;
@property (nonatomic, readonly) NSMutableArray *movedItems;

#pragma mark Fetch Offset & Limit
@property (nonatomic, readonly) BOOL hasOffsetOrLimit;
@end

@implementation NXFetchedCollectionViewDataSource

#pragma mark Life-cycle

- (id)initWithCollectionView:(UICollectionView *)collectionView managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [super initWithCollectionView:collectionView];
    if (self) {
        _managedObjectContext = managedObjectContext;
        
        _insertedSections = [[NSMutableIndexSet alloc] init];
        _deletedSections = [[NSMutableIndexSet alloc] init];
        
        _insertedItems = [[NSMutableArray alloc] init];
        _deletedItems = [[NSMutableArray alloc] init];
        _movedItems = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark Getting Item and Section Metrics

- (NSInteger)numberOfSections
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

#pragma mark Getting Items and Index Paths

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSArray *)indexPathsOfItem:(id)item;
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:item];
    if (indexPath) {
        return @[indexPath];
    } else {
        return @[];
    }
}

- (NSArray *)fetchedItems
{
    return self.fetchedResultsController.fetchedObjects;
}

#pragma mark Getting Section Name

- (NSString *)nameForSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo name];
}


#pragma mark Reload

- (void)reload
{
    [self reloadWithFetchRequest:self.fetchRequest sectionKeyPath:self.sectionKeyPath];
}

- (void)reloadWithFetchRequest:(NSFetchRequest *)fetchRequest sectionKeyPath:(NSString *)sectionKeyPath
{
    self.fetchRequest = fetchRequest;
    self.sectionKeyPath = sectionKeyPath;
    
    BOOL success = YES;
    
    if (fetchRequest) {
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:self.sectionKeyPath
                                                                                       cacheName:nil];
        self.fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        success = [self.fetchedResultsController performFetch:&error];
        NSAssert(success, [error localizedDescription]);
    } else {
        self.fetchedResultsController = nil;
    }
    
    if (success) {
        [super reload];
    }
}

- (void)reset
{
    [self reloadWithFetchRequest:nil sectionKeyPath:nil];
}

#pragma mark Fetch Offset & Limit

- (BOOL)hasOffsetOrLimit
{
    return self.fetchRequest.fetchOffset > 0 || self.fetchRequest.fetchLimit > 0;
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.insertedSections removeAllIndexes];
    [self.deletedSections removeAllIndexes];
    [self.insertedItems removeAllObjects];
    [self.deletedItems removeAllObjects];
    [self.movedItems removeAllObjects];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.insertedSections addIndex:sectionIndex];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.deletedSections addIndex:sectionIndex];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.insertedItems addObject:newIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.movedItems addObject:@[indexPath, newIndexPath]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.deletedItems addObject:indexPath];
            break;
            
        case NSFetchedResultsChangeUpdate:
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Filter Changes
    // --------------
    
    NSIndexSet *insertedSections = [self.insertedSections copy];
    NSIndexSet *deletedSections = [self.deletedSections copy];
    
    NSPredicate *indexPathFilter = [NSPredicate predicateWithBlock:^BOOL(NSIndexPath *indexPath, NSDictionary *bindings) {
        
        if ([insertedSections containsIndex:indexPath.section]) {
            return NO;
        }
        
        if ([deletedSections containsIndex:indexPath.section]) {
            return NO;
        }
        
        return YES;
    }];
    
    NSMutableArray *insertedItems = [[self.insertedItems filteredArrayUsingPredicate:indexPathFilter] mutableCopy];
    NSMutableArray *deletedItems = [[self.deletedItems filteredArrayUsingPredicate:indexPathFilter] mutableCopy];
    
    NSArray *movedItems = [self.movedItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSArray *move, NSDictionary *bindings) {
        
        NSIndexPath *from = [move firstObject];
        NSIndexPath *to = [move lastObject];
        
        // Item comes from a section has has been deleted
        if ([deletedSections containsIndex:from.section]) {
         
            NSUInteger sectionOffset = [[deletedSections indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
                return idx <= to.section;
            }] count];
            
            // … and goes to an other section
            if ([insertedSections containsIndex:to.section + sectionOffset] == NO && [deletedSections containsIndex:to.section + sectionOffset] == NO)
                [insertedItems addObject:to];
            
            return NO;
        }
        
        // Item goes to a section has has been inserted
        if ([insertedSections containsIndex:to.section]) {
            
            NSUInteger sectionOffset = [[insertedSections indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
                return idx <= from.section;
            }] count];
            
            // … and comes from an exsiting section
            if ([insertedSections containsIndex:from.section + sectionOffset] == NO && [deletedSections containsIndex:from.section + sectionOffset] == NO)
                [deletedItems addObject:from];
            
            return NO;
        }
        
        return YES;
    }]];
    
    BOOL hasChanges = [insertedSections count] > 0;
    hasChanges = hasChanges || [deletedSections count] > 0;
    hasChanges = hasChanges || [insertedItems count] > 0;
    hasChanges = hasChanges || [deletedItems count] > 0;
    hasChanges = hasChanges || [movedItems count] > 0;
    
    // Perform Changes
    // ---------------
    
    if (hasChanges) {
        
        if (self.hasOffsetOrLimit) {
            
            // WORKAROUND: If the fetch offset or fetch limit is set, the collection view needs to reload,
            //             because the NSFetchedResultsController ignors this while handling the updates.
            
            [self reload];
            return;
        }
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteSections:deletedSections];
            [self.collectionView insertSections:insertedSections];
            
            [self.collectionView insertItemsAtIndexPaths:insertedItems];
            [self.collectionView deleteItemsAtIndexPaths:deletedItems];
            
            [movedItems enumerateObjectsUsingBlock:^(NSArray *move, NSUInteger idx, BOOL *stop) {
                NSIndexPath *from = [move objectAtIndex:0];
                NSIndexPath *to = [move objectAtIndex:1];
                [self.collectionView moveItemAtIndexPath:from toIndexPath:to];
            }];
        } completion:^(BOOL finished) {
            
        }];
        
        if (self.postUpdateBlock) {
            self.postUpdateBlock(self);
        }
    }
}

@end
