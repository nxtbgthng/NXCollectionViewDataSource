//
//  NXFetchedCollectionViewDataSource.h
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "NXCollectionViewDataSource.h"

@class NXFetchedCollectionViewDataSource;

@interface NXFetchedCollectionViewDataSource : NXCollectionViewDataSource

#pragma mark Life-cycle
- (id)initWithCollectionView:(UICollectionView *)collectionView managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

#pragma mark Core Data Properties
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSString *sectionKeyPath;

#pragma mark Getting Items and Index Paths
@property (nonatomic, readonly) NSArray *fetchedItems;

#pragma mark Reload
- (void)reloadWithFetchRequest:(NSFetchRequest *)fetchRequest sectionKeyPath:(NSString *)sectionKeyPath;
- (void)reloadWithFetchRequest:(NSFetchRequest *)fetchRequest sectionRelationshipDescription:(NSRelationshipDescription *)relationshipDescription;

@end
