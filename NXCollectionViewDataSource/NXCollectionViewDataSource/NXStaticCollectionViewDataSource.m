//
//  NXStaticCollectionViewDataSource.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXStaticCollectionViewDataSource.h"

@implementation NXStaticCollectionViewDataSource

#pragma mark Life-cycle

- (id)initWithSections:(NSArray *)sections sectionNames:(NSArray *)sectionNames forCollectionView:(UICollectionView *)collectionView
{
    self = [super initWithCollectionView:collectionView];
    if (self) {
        _sections = sections;
        _sectionNames = sectionNames;
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

@end