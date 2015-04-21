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

/*! A reference to the UICollectionVIew managed by this data source.
 */
@property (nonatomic, readonly, weak) UICollectionView *collectionView;

#pragma mark Register Cell and Supplementary View Classes
/*! Registers an already existing storyboard cell for items that match a specific predicate.
    @param predicate        A predicate that is used to determine for which items the given cellClass is used. Every predicate will be collected with the given reuseIdentifier.
                            All collected predicates will be iterated in the same order as they were registered. While generating the cells for the collection view, the first
                            predicate/reuseIdentifier-pair that matches to the current item will be used for dequeuing the correct cell view from the collection view.
                            The predicate will be evaluated with the variables "SECTION" and "ITEM", allowing to choose the cell based on the index path.
    @param prepareBlock     A Block which is called to prepare the view. This block is called after the data source internally dequeues the view.
    @param reuseIdentifier  The reuseIdentifier used by the existing storyboard cell.
*/
- (void)setPredicate:(NSPredicate *)predicate andPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock forReuseIdentifier:(NSString *)reuseIdentifier;

/*! Registers a Class used to create the cells for the collection view, for items that match a specific predicate.
 
    @param cellClass        The class of a cell that you want to use in the collection view.
    @param reuseIdentifier  The reuseIdentifier that is used to register the given cellClass at (and dequeue a view from) the collection view. If a reuseIdentifer is used
                            twice, the old cellClass, predicate und prepareBlock will be overridden.
    @param predicate        A predicate that is used to determine for which items the given cellClass is used. Every predicate will be collected with the given reuseIdentifier.
                            All collected predicates will be iterated in the same order as they were registered. While generating the cells for the collection view, the first 
                            predicate/reuseIdentifier-pair that matches to the current item will be used for dequeuing the correct cell view from the collection view.
                            The predicate will be evaluated with the variables "SECTION" and "ITEM", allowing to choose the cell based on the index path.
    @param prepareBlock     A Block which is called to prepare the view. This block is called after the data source internally dequeues the view.
 */
- (void)registerClass:(Class)cellClass withReuseIdentifier:(NSString *)reuseIdentifier forItemsMatchingPredicate:(NSPredicate *)predicate withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock;

/*! Registers a Nib used to create the cells for the collection view, for items that match a specific predicate.
 
    @param nib              The Nib of a cell that you want to use in the collection view.
    @param reuseIdentifier  The reuseIdentifier that is used to register the given cellClass at (and dequeue a view from) the collection view. If a reuseIdentifer is used
                            twice, the old cellClass, predicate und prepareBlock will be overridden.
    @param predicate        A predicate that is used to determine for which items the given cellClass is used. Every predicate will be collected with the given reuseIdentifier.
                            All collected predicates will be iterated in the same order as they were registered. While generating the cells for the collection view, the first
                            predicate/reuseIdentifier-pair that matches to the current item will be used for dequeuing the correct cell view from the collection view.
                            The predicate will be evaluated with the variables "SECTION" and "ITEM", allowing to choose the cell based on the index path.
    @param prepareBlock     A Block which is called to prepare the view. This block is called after the data source internally dequeues the view.
 */
- (void)registerNib:(UINib *)nib withReuseIdentifier:(NSString *)reuseIdentifier forItemsMatchingPredicate:(NSPredicate *)predicate withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock;

/*! A convenience method that registers the given cellClass with a "always YES" predicate and a static reuseIdentifer. You may use that method to register a default/fallback
    cellClass by calling it in the end, after any other cellClass has been registered. You can also use it, to have always the same cellClass for every item in the collection view.
 
    @param cellClass The class of a cell that you want to use in the collection view.
    @param prepareBlock A Block which is called to prepare the cell. This block is called after the data source internally dequeues the cell.
 */
- (void)registerClass:(Class)cellClass withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock;

/*! A convenience method that registers the given cellClass with a "always YES" predicate and a static reuseIdentifer. You may use that method to register a default/fallback
    cellClass by calling it in the end, after any other cellClass has been registered. You can also use it, to have always the same cellClass for every item in the collection view.
 
    @param nib The Nib of a cell that you want to use in the collection view.
    @param prepareBlock A Block which is called to prepare the cell. This block is called after the data source internally dequeues the cell.
 */
- (void)registerNib:(UINib *)nib withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock;


/*! Register a Class used to create supplementary views for the collection view.
 
    @param viewClass The class to use for the supplementary view.
    @param elementKind The kind of supplementary view to create. This value is defined by the layout object. This parameter must not be nil.
    @param prepareBlock A Block which is called to prepare the view. This block is called after the data source internally dequeues the view.
 */
- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock;
- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString *)elementKind withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock;

#pragma mark Getting Item and Section Metrics
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

#pragma mark Getting Items and Index Paths
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)indexPathsOfItem:(id)item;

#pragma mark Getting Section Item
- (id)itemForSection:(NSInteger)section;

#pragma mark Reload & Reset
- (void)reload;
- (void)reset;

#pragma mark Post Update
@property (copy) NXCollectionViewDataSourcePostUpdateBlock postUpdateBlock;

@end

// Import Subclasses to have a Framework Header

#import "NXStaticCollectionViewDataSource.h"
#import "NXFetchedCollectionViewDataSource.h"
