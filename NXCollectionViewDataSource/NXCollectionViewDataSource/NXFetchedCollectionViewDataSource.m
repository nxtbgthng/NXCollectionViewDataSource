//
//  NXFetchedCollectionViewDataSource.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import <objc/runtime.h>

#import "NXFetchedCollectionViewDataSource.h"

typedef enum {
    NXFetchedCollectionViewDataSourceSectionBehaviourDEFAULT = 0,
    NXFetchedCollectionViewDataSourceSectionBehaviourRELATIONSHIP,
    
} NXFetchedCollectionViewDataSourceSectionBehaviour;

@interface NXFetchedCollectionViewDataSource () <NSFetchedResultsControllerDelegate>
#pragma mark Core Data Properties
@property (nonatomic, readwrite, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, readwrite, strong) NSString *sectionKeyPath;
@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;

#pragma mark Section Behaviour
@property (nonatomic, assign) NXFetchedCollectionViewDataSourceSectionBehaviour sectionBehaviour;

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

#pragma mark Getting Section Item

- (id)itemForSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    if (sectionInfo) {
        switch (self.sectionBehaviour) {
            case NXFetchedCollectionViewDataSourceSectionBehaviourRELATIONSHIP:
                if ([sectionInfo.name hasPrefix:@"x-coredata://"]) {
                    NSURL *URL = [NSURL URLWithString:sectionInfo.name];
                    NSManagedObjectID *managedObjectID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:URL];
                    NSError *error = nil;
                    NSManagedObject *sectionObject = [self.managedObjectContext existingObjectWithID:managedObjectID error:&error];
                    NSAssert(error == nil, [error localizedDescription]);
                    return sectionObject;
                } else {
                    return nil;
                }
                
            default:
                return sectionInfo.name;
                break;
        }
    } else {
        return nil;
    }
}

#pragma mark Reload

- (void)reload
{
    [self reloadWithFetchRequest:self.fetchRequest sectionKeyPath:self.sectionKeyPath sectionBehaviour:self.sectionBehaviour];
}

- (void)reloadWithFetchRequest:(NSFetchRequest *)fetchRequest sectionKeyPath:(NSString *)sectionKeyPath
{
    [self reloadWithFetchRequest:fetchRequest sectionKeyPath:sectionKeyPath sectionBehaviour:NXFetchedCollectionViewDataSourceSectionBehaviourDEFAULT];
}

- (void)reloadWithFetchRequest:(NSFetchRequest *)fetchRequest sectionKeyPath:(NSString *)sectionKeyPath sectionBehaviour:(NXFetchedCollectionViewDataSourceSectionBehaviour)sectionBehaviour
{
    self.fetchRequest = fetchRequest;
    self.sectionKeyPath = sectionKeyPath;
    
    BOOL success = YES;
    
    self.sectionBehaviour = sectionBehaviour;
    
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

- (void)reloadWithFetchRequest:(NSFetchRequest *)fetchRequest sectionRelationshipDescription:(NSRelationshipDescription *)relationshipDescription
{
    NSParameterAssert([relationshipDescription isToMany] == NO);
    
    NSString *sectionKeyPath = [NSString stringWithFormat:@"NXFetchedCollectionViewDataSource_%@", relationshipDescription.name];
    
    Class managedObjectClass = NSClassFromString([relationshipDescription.entity managedObjectClassName]);
    SEL selector = NSSelectorFromString(sectionKeyPath);
    
    if ([managedObjectClass instancesRespondToSelector:selector] == NO) {
        class_addMethod(managedObjectClass, selector, imp_implementationWithBlock(^(NSManagedObject *self) {
            NSManagedObject *relatedObject = [self valueForKey:relationshipDescription.name];
            if (relatedObject) {
                return [[relatedObject.objectID URIRepresentation] absoluteString];
            } else {
                return @"";
            }
        }), "@@:");
    }
    
    [self reloadWithFetchRequest:fetchRequest sectionKeyPath:sectionKeyPath sectionBehaviour:NXFetchedCollectionViewDataSourceSectionBehaviourRELATIONSHIP];
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
    
    NSArray *insertedItems = [self.insertedItems filteredArrayUsingPredicate:indexPathFilter];
    NSArray *deletedItems = [self.deletedItems filteredArrayUsingPredicate:indexPathFilter];
    
    NSArray *movedItems = [self.movedItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSArray *move, NSDictionary *bindings) {
        
        NSIndexPath *from = [move objectAtIndex:0];
        NSIndexPath *to = [move objectAtIndex:1];
        
        NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] init];
        [sections addIndex:from.section];
        [sections addIndex:to.section];
        
        if ([insertedSections containsIndexes:sections]) {
            return NO;
        }
        
        if ([deletedSections containsIndexes:sections]) {
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
