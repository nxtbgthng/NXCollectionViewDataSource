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

typedef void(^NXFetchedCollectionViewDataSourcePostUpdateBlock)(NXFetchedCollectionViewDataSource *dataSource, NSDictionary *update);

@interface NXFetchedCollectionViewDataSource : NXCollectionViewDataSource

#pragma mark Life-cycle
- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest sectionKeyPath:(NSString *)sectionKeyPath managedObjectContext:(NSManagedObjectContext *)managedObjectContext forCollectionView:(UICollectionView *)collectionView;

#pragma mark Post Update
@property (copy) NXFetchedCollectionViewDataSourcePostUpdateBlock postUpdateBlock;

#pragma mark Core Data Properties
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSString *sectionKeyPath;

#pragma mark Reload
- (BOOL)reloadWithFetchRequest:(NSFetchRequest *)fetchRequest sectionKeyPath:(NSString *)sectionKeyPath;

@end
