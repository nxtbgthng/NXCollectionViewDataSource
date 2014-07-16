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

#pragma mark Cell Predicates & Prepare Blocks
@property (nonatomic, readonly) NSMutableDictionary *predicates;
@property (nonatomic, readonly) NSMutableDictionary *prepareBlocks;

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
        
        _predicates = [NSMutableDictionary dictionary];
        _prepareBlocks = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark Register Cell and Supplementary View Classes

- (void)registerClass:(Class)cellClass withReuseIdentifier:(NSString *)reuseIdentifier forItemsMatchingPredicate:(NSPredicate *)predicate withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    [self.predicates setObject:predicate forKey:reuseIdentifier];
    [self.prepareBlocks setObject:prepareBlock forKey:reuseIdentifier];
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)registerNib:(UINib *)nib withReuseIdentifier:(NSString *)reuseIdentifier forItemsMatchingPredicate:(NSPredicate *)predicate withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    [self.predicates setObject:predicate forKey:reuseIdentifier];
    [self.prepareBlocks setObject:prepareBlock forKey:reuseIdentifier];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)registerClass:(Class)cellClass withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    [self registerClass:cellClass withReuseIdentifier:NXCollectionViewDataSourceCellReuseIdentifier forItemsMatchingPredicate:[NSPredicate predicateWithValue:YES] withPrepareBlock:prepareBlock];
}

- (void)registerNib:(UINib *)nib withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    [self registerNib:nib withReuseIdentifier:NXCollectionViewDataSourceCellReuseIdentifier forItemsMatchingPredicate:[NSPredicate predicateWithValue:YES] withPrepareBlock:prepareBlock];
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

//Get the matching reuseIdentifier for an item based on collected predicates
- (NSString *)reuseIdentifierForItem:(id)item
{
    if (item) {
        for (NSString *tmpReuseIdentifier in self.predicates) {
            NSPredicate *tmpPredicate = [self.predicates objectForKey:tmpReuseIdentifier];
            if (tmpPredicate && [tmpPredicate evaluateWithObject:item]) {
                return tmpReuseIdentifier;
            }
        }
    }
    return nil;
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

#pragma mark Getting Section Item

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
        NSString *reuseIdentifier = [self reuseIdentifierForItem:[self itemAtIndexPath:indexPath]];
        if (reuseIdentifier) {
            UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
            NSAssert([cell.reuseIdentifier isEqualToString:reuseIdentifier], @"Class %@ has been registered with reuse identifier '%@' but has the reuse identifier '%@'. Method -[UICollectionReusableView reuseIdentifier] must not be overloaded by a subclass. ", [cell class], reuseIdentifier, cell.reuseIdentifier);
            
            //Get and call the prepare block
            NXCollectionViewDataSourcePrepareBlock prepareBlock = [self.prepareBlocks objectForKey:reuseIdentifier];
            if (cell && prepareBlock) {
                prepareBlock(cell, indexPath, self);
            }
            
            return cell;
        }
    }
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        UICollectionReusableView *view = [self.collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:elementKind forIndexPath:indexPath];
        NSAssert([view.reuseIdentifier isEqualToString:elementKind], @"Class %@ has been registered with reuse identifier '%@' but has the reuse identifier '%@'. Method -[UICollectionReusableView reuseIdentifier] must not be overloaded by a subclass. ", [view class], elementKind, view.reuseIdentifier);
        NXCollectionViewDataSourcePrepareBlock prepareBlock = self.supplementaryViewPrepareBlock[elementKind];
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
