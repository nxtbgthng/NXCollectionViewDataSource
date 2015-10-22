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

NS_ASSUME_NONNULL_BEGIN

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
- (void)reloadWithFetchRequest:(NSFetchRequest * __nullable)fetchRequest sectionKeyPath:(NSString * __nullable)sectionKeyPath;
- (void)reloadWithFetchRequest:(NSFetchRequest * __nullable)fetchRequest sectionAttributeDescription:(NSAttributeDescription *)attributeDescription;
- (void)reloadWithFetchRequest:(NSFetchRequest * __nullable)fetchRequest sectionRelationshipDescription:(NSRelationshipDescription *)relationshipDescription;

#pragma mark Relaod Colelction View
@property (nonatomic, assign) BOOL reloadCollectionViewAfterChanges;

@end

NS_ASSUME_NONNULL_END