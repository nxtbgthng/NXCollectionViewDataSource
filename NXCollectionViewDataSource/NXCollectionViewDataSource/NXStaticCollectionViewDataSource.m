//
//  NXStaticCollectionViewDataSource.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXStaticCollectionViewDataSource.h"

@interface NXStaticCollectionViewDataSource ()
@property (nonatomic, readonly) NSMutableDictionary *items;
@end

@implementation NXStaticCollectionViewDataSource

#pragma mark Life-cycle

- (id)initWithSections:(NSArray *)sections sectionNames:(NSArray *)sectionNames forCollectionView:(UICollectionView *)collectionView
{
    self = [super initWithCollectionView:collectionView];
    if (self) {
        _sections = sections;
        _sectionNames = sectionNames;
        
        _items = [[NSMutableDictionary alloc] init];
        [_sections enumerateObjectsUsingBlock:^(NSArray *section, NSUInteger sectionIndex, BOOL *stop) {
            [section enumerateObjectsUsingBlock:^(id item, NSUInteger itemIndex, BOOL *stop) {
                [_items setObject:item forKey:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
            }];
        }];
    }
    return self;
}

#pragma mark Getting Item and Section Metrics

- (NSUInteger)numberOfSections
{
    return [self.sections count];
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section
{
    return [self.sections[section] count];
}

#pragma mark Getting Items and Index Paths

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.items objectForKey:indexPath];
}

- (NSArray *)indexPathsOfItem:(id)item;
{
    return [self.items allKeysForObject:item];
}

@end