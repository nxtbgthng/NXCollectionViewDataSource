//
//  NXCollectionViewDataSource.h
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NXCollectionViewDataSource;

typedef void(^NXCollectionViewDataSourcePrepareBlock)(id view, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource);
typedef void(^NXCollectionViewDataSourcePostUpdateBlock)(NXCollectionViewDataSource *dataSource);

@interface NXCollectionViewDataSource : NSObject <UICollectionViewDataSource>

#pragma mark Life-cycle
- (id)initWithCollectionView:(UICollectionView *)collectionView;

#pragma mark Collection View
@property (nonatomic, readonly, weak) UICollectionView *collectionView;

#pragma mark Register Cell and Supplementary View Classes
- (void)registerClass:(Class)cellClass withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock;
- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock;

#pragma mark Getting Item and Section Metrics
- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfItemsInSection:(NSUInteger)section;

#pragma mark Getting Items and Index Paths
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)indexPathsOfItem:(id)item;

#pragma mark Getting Section Name
- (NSString *)nameForSection:(NSUInteger)section;

#pragma mark Reload
- (void)reload;

#pragma mark Post Update
@property (copy) NXCollectionViewDataSourcePostUpdateBlock postUpdateBlock;

@end
