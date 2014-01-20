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

/*! Initialize the data source with a collection view.
 
    The data source sets it self as a collection view data source on the
    collection view and keeps a weak reference to the collection view.
 
    @param collectionView The UICollectionView this data source should manage.
 */
- (id)initWithCollectionView:(UICollectionView *)collectionView;

#pragma mark Collection View

/*! A reference to the UICollectionVIew manegd by this data source.
 */
@property (nonatomic, readonly, weak) UICollectionView *collectionView;

#pragma mark Register Cell and Supplementary View Classes

/*! Registers a Class used to create the cells for the collection view.
 
    @param cellClass The class of a cell that you want to use in the collection view.
    @param prepareBlock A Block which is called to prepare the cell. This block is called after the data source internaly dequeues the cell.
 */
- (void)registerClass:(Class)cellClass withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock;

/*! Register a Class used to create supplementary views for the collection view.
 
    @param viewClass The class to use for the supplementary view.
    @param elementKind The kind of supplementary view to create. This value is defined by the layout object. This parameter must not be nil.
    @param prepareBlock A Block which is called to prepare the view. This block is called after the data source internaly dequeues the view.
 */
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
