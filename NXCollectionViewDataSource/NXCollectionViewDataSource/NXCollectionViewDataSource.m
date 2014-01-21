//
//  NXCollectionViewDataSource.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXCollectionViewDataSource.h"
#import "NXCollectionViewDataSource+Private.h"

@interface NXCollectionViewDataSource ()
#pragma mark Collection View Cells
@property (nonatomic, readwrite, strong) NSString *cellReuseIdentifier;
@property (nonatomic, readwrite, strong) NXCollectionViewDataSourcePrepareBlock cellPrepareBlock;

#pragma mark Collection View Supplementary View
@property (nonatomic, readonly) NSMutableDictionary *supplementaryViewReuseIdentifier;
@property (nonatomic, readonly) NSMutableDictionary *supplementaryViewPrepareBlock;
@end

@implementation NXCollectionViewDataSource

#pragma mark Life-cycle

- (id)initWithCollectionView:(UICollectionView *)collectionView;
{
    self = [super  init];
    if (self) {
        _collectionView = collectionView;
        _collectionView.dataSource = self;
        
        _supplementaryViewReuseIdentifier = [[NSMutableDictionary alloc] init];
        _supplementaryViewPrepareBlock = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Register Cell and Supplementary View Classes

- (void)registerClass:(Class)cellClass withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    self.cellReuseIdentifier = NSStringFromClass(cellClass);
    self.cellPrepareBlock = prepareBlock;
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:self.cellReuseIdentifier];
}

- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    NSString *reuseIdentifier = NSStringFromClass(viewClass);
    self.supplementaryViewReuseIdentifier[elementKind] = reuseIdentifier;
    self.supplementaryViewPrepareBlock[elementKind] = prepareBlock;
    [self.collectionView registerClass:viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:reuseIdentifier];
}

#pragma mark Getting Item and Section Metrics

- (NSUInteger)numberOfSections
{
    return 0;
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section
{
    return 0;
}

#pragma mark Getting Items and Index Paths

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSArray *)indexPathsOfItem:(id)item;
{
    return @[];
}

#pragma mark Getting Section Name

- (NSString *)nameForSection:(NSUInteger)section
{
    return nil;
}

#pragma mark Reload

- (void)reload
{
    [self.collectionView reloadData];
    if (self.postUpdateBlock) {
        self.postUpdateBlock(self);
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == self.collectionView) {
        return [self numberOfSections];
    } else {
        return 0;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return [self numberOfItemsInSection:section];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];
        if (cell && self.cellPrepareBlock) {
            self.cellPrepareBlock(cell, indexPath, self);
        }
        return cell;
    } else {
        return nil;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        NSString *reuseIdentifier = self.supplementaryViewReuseIdentifier[kind];
        NXCollectionViewDataSourcePrepareBlock prepareBlock = self.supplementaryViewPrepareBlock[kind];
        
        UICollectionReusableView *view = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        if (view && prepareBlock) {
            prepareBlock(view, indexPath, self);
        }
        return view;
    } else {
        return nil;
    }
}

@end

@implementation NXCollectionViewDataSource (Private)

@end
