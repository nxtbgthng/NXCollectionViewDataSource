//
//  NXFetchedCollectionViewDataSource.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXFetchedCollectionViewDataSource.h"

@implementation NXFetchedCollectionViewDataSource

#pragma mark Life-cycle

- (id)initWithCollectionView:(UICollectionView *)collectionView managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [super initWithCollectionView:collectionView];
    if (self) {
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

#pragma mark Reload

- (void)reloadWithFetchRequest:(NSFetchRequest *)fetchRequest sectionKeyPath:(NSString *)sectionKeyPath
{
    [self reload];
}

@end
