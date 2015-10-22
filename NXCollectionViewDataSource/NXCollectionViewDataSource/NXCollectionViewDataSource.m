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

@interface NXCollectionViewDataSourcePredicateWrapper : NSObject

@property (nonatomic, readonly) NSString *reuseIdentifier;
@property (nonatomic, readonly) NSPredicate *predicate;

- (id)initWithPredicate:(NSPredicate *)predicate reuseIdentifier:(NSString *)reuseIdentifier;

@end

@implementation NXCollectionViewDataSourcePredicateWrapper

-(id)initWithPredicate:(NSPredicate *)predicate reuseIdentifier:(NSString *)reuseIdentifier
{
    NSParameterAssert(predicate);
    NSParameterAssert(reuseIdentifier);
    self = [super init];
    if (self) {
        _reuseIdentifier = reuseIdentifier;
        _predicate = predicate;
    }
    return self;
}

@end

@interface NXCollectionViewDataSource ()

#pragma mark Cell Predicates & Prepare Blocks
@property (nonatomic, readonly) NSMutableArray *predicateWrappers;
@property (nonatomic, readonly) NSMutableDictionary *prepareBlocks;

#pragma mark Collection View Supplementary View
@property (nonatomic, readonly) NSMutableDictionary *supplementaryViewPrepareBlock;

@end

@implementation NXCollectionViewDataSource

#pragma mark Life-cycle

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;
{
    NSParameterAssert(collectionView);
    
    self = [super  init];
    if (self) {
        _collectionView = collectionView;
        _collectionView.dataSource = self;
        
        _supplementaryViewPrepareBlock = [[NSMutableDictionary alloc] init];
        
        _predicateWrappers = [NSMutableArray array];
        _prepareBlocks = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark Register Cell and Supplementary View Classes

- (void)registerClass:(Class)cellClass withReuseIdentifier:(NSString *)reuseIdentifier forItemsMatchingPredicate:(NSPredicate *)predicate withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    if (cellClass) {
        [self setPredicate:predicate andPrepareBlock:prepareBlock forReuseIdentifier:reuseIdentifier];
    } else {
        [self removePredicateAndPrepareBlockForReuseIdentifier:reuseIdentifier];
    }
    
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)registerNib:(UINib *)nib withReuseIdentifier:(NSString *)reuseIdentifier forItemsMatchingPredicate:(NSPredicate *)predicate withPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock
{
    if (nib) {
        [self setPredicate:predicate andPrepareBlock:prepareBlock forReuseIdentifier:reuseIdentifier];
    } else {
        [self removePredicateAndPrepareBlockForReuseIdentifier:reuseIdentifier];
    }
    
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


#pragma mark Manage Predicates & Prepare-Blocks

- (NXCollectionViewDataSourcePredicateWrapper *)lookupExistingPredicateWrapperForReuseIdentifier:(NSString *)reuseIdentifier
{
    for(NXCollectionViewDataSourcePredicateWrapper *tmpWrapper in self.predicateWrappers) {
        if ([tmpWrapper.reuseIdentifier isEqualToString:reuseIdentifier]) {
            return tmpWrapper;
        }
    }
    return nil;
}

- (void)setPredicate:(NSPredicate *)predicate andPrepareBlock:(NXCollectionViewDataSourcePrepareBlock)prepareBlock forReuseIdentifier:(NSString *)reuseIdentifier
{
    NXCollectionViewDataSourcePredicateWrapper *newWrapper = [[NXCollectionViewDataSourcePredicateWrapper alloc] initWithPredicate:predicate reuseIdentifier:reuseIdentifier];
    
    //Remove if Wrapper for reuseIdentifier already exists
    NXCollectionViewDataSourcePredicateWrapper *existingWrapper = [self lookupExistingPredicateWrapperForReuseIdentifier:reuseIdentifier];
    if (existingWrapper) {
        [self.predicateWrappers removeObject:existingWrapper];
    }
    
    [self.predicateWrappers addObject:newWrapper];
    [self.prepareBlocks setObject:prepareBlock forKey:reuseIdentifier];
}

- (void)removePredicateAndPrepareBlockForReuseIdentifier:(NSString *)reuseIdentifier
{
    NXCollectionViewDataSourcePredicateWrapper *existingWrapper = [self lookupExistingPredicateWrapperForReuseIdentifier:reuseIdentifier];
    if (existingWrapper) {
        [self.predicateWrappers removeObject:existingWrapper];
        [self.prepareBlocks removeObjectForKey:reuseIdentifier];
    }
}

- (NSString *)reuseIdentifierForItem:(id)item atIndexPath:(NSIndexPath *)indexPath
{
    if (item) {
        for (NXCollectionViewDataSourcePredicateWrapper *tmpWrapper in self.predicateWrappers) {
            
            NSDictionary *substitutionVariables = @{@"SECTION": @(indexPath.section),
                                                    @"ITEM":    @(indexPath.item)};
            
            if ([tmpWrapper.predicate evaluateWithObject:item substitutionVariables:substitutionVariables]) {
                return tmpWrapper.reuseIdentifier;
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
        NSString *reuseIdentifier = [self reuseIdentifierForItem:[self itemAtIndexPath:indexPath] atIndexPath:indexPath];
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
