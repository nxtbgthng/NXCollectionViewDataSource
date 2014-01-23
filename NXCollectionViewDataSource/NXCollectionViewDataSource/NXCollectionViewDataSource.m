//
//  NXCollectionViewDataSource.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXCollectionViewDataSource.h"
#import "NXCollectionViewDataSource+Private.h"

NSString * const NXCollectionViewDataSourceCellReuseIdentifier = @"NXCollectionViewDataSourceCellReuseIdentifier";

@interface NXCollectionViewDataSource ()
@property (nonatomic, readwrite, strong) NXCollectionViewDataSourcePrepareBlock cellPrepareBlock;

#pragma mark Collection View Supplementary View
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
        
        _supplementaryViewPrepareBlock = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Register Cell and Supplementary View Classes

- (void)registerClass:(Class)cellClass withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    self.cellPrepareBlock = prepareBlock;
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:NXCollectionViewDataSourceCellReuseIdentifier];
}

- (void)registerNib:(UINib *)nib withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    self.cellPrepareBlock = prepareBlock;
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:NXCollectionViewDataSourceCellReuseIdentifier];
}

- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    if (prepareBlock) {
        [self.supplementaryViewPrepareBlock setObject:prepareBlock forKey:elementKind];
    } else {
        [self.supplementaryViewPrepareBlock removeObjectForKey:elementKind];
    }
    [self.collectionView registerClass:viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:elementKind];
}

- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString *)elementKind withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    if (prepareBlock) {
        [self.supplementaryViewPrepareBlock setObject:prepareBlock forKey:elementKind];
    } else {
        [self.supplementaryViewPrepareBlock removeObjectForKey:elementKind];
    }
    [self.collectionView registerNib:nib forSupplementaryViewOfKind:elementKind withReuseIdentifier:elementKind];
}

#pragma mark Getting Item and Section Metrics

- (NSInteger)numberOfSections
{
    return 0;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
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

- (NSString *)nameForSection:(NSInteger)section
{
    return nil;
}

#pragma mark Section Item

- (id)itemForSection:(NSInteger)section
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

- (void)reset
{
    
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
        UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NXCollectionViewDataSourceCellReuseIdentifier forIndexPath:indexPath];
        if (cell && self.cellPrepareBlock) {
            self.cellPrepareBlock(cell, indexPath, self);
        }
        return cell;
    } else {
        return nil;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        NXCollectionViewDataSourcePrepareBlock prepareBlock = self.supplementaryViewPrepareBlock[elementKind];
        
        UICollectionReusableView *view = [self.collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:elementKind forIndexPath:indexPath];
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
