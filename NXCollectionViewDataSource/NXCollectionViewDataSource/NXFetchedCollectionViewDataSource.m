//
//  NXFetchedCollectionViewDataSource.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXFetchedCollectionViewDataSource.h"

@interface NXFetchedCollectionViewDataSource ()
#pragma mark Core Data Properties
@property (nonatomic, readwrite, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, readwrite, strong) NSString *sectionKeyPath;
@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation NXFetchedCollectionViewDataSource

#pragma mark Life-cycle

- (id)initWithCollectionView:(UICollectionView *)collectionView managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [super initWithCollectionView:collectionView];
    if (self) {
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

#pragma mark Getting Item and Section Metrics

- (NSUInteger)numberOfSections
{
    return [[self.fetchedResultsController sections] count];
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section
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
    return @[[self.fetchedResultsController indexPathForObject:item]];
}

#pragma mark Getting Section Name

- (NSString *)nameForSection:(NSUInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo name];
}


#pragma mark Reload

- (void)reloadWithFetchRequest:(NSFetchRequest *)fetchRequest sectionKeyPath:(NSString *)sectionKeyPath
{
    self.fetchRequest = fetchRequest;
    self.sectionKeyPath = sectionKeyPath;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:self.sectionKeyPath
                                                                                   cacheName:nil];
    
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    
    [self reload];
}

@end
