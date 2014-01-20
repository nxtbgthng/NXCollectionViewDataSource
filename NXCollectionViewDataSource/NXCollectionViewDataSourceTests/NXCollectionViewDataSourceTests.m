//
//  NXCollectionViewDataSourceTests.m
//  NXCollectionViewDataSourceTests
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>

#import "NXCollectionViewDataSource.h"
#import "NXCollectionViewDataSource+Private.h"

@interface NXCollectionViewDataSourceTests : XCTestCase

@end

@implementation NXCollectionViewDataSourceTests

#pragma mark Tests

- (void)testSetup
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXCollectionViewDataSource *dataSource = [[NXCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    
    XCTAssertNotNil(dataSource);
    XCTAssertEqual(dataSource.collectionView, collectionView);
}

- (void)testGettingItemAndSectionMetrics
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXCollectionViewDataSource *dataSource = [[NXCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    
    NSInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:collectionView];
    XCTAssertEqual(numberOfSections, 0, @"The base data source should always be empty.");
}

- (void)testRegisterCellClass
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    NXCollectionViewDataSource *dataSource = [[NXCollectionViewDataSource alloc] initWithCollectionView:collectionView];

    NXCollectionViewDataSourcePrepareBlock cellPrepareBlock = ^(id view, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource) {};
    
    [dataSource registerClass:[UICollectionViewCell class] withPrepareBlock:cellPrepareBlock];
    
    // The class should be registerd in the collection view.
    [verifyCount(collectionView, times(1)) registerClass:[UICollectionViewCell class]
                              forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    // The data source sould keep track of the prepare block and the reuse identifier.
    XCTAssertEqual(dataSource.cellPrepareBlock, cellPrepareBlock);
    XCTAssertEqualObjects(dataSource.cellReuseIdentifier, @"UICollectionViewCell");
}

- (void)testRegisterSupplementaryViewClasses
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    NXCollectionViewDataSource *dataSource = [[NXCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    
    NXCollectionViewDataSourcePrepareBlock supplementaryViewPrepareBlock = ^(id view, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource) {};
    NSString *supplementaryViewKind = @"supplementaryViewKind";
    
    [dataSource registerClass:[UIView class] forSupplementaryViewOfKind:supplementaryViewKind withPrepareBlock:supplementaryViewPrepareBlock];
    
    // The class should be registerd in the collection view.
    [verifyCount(collectionView, times(1)) registerClass:[UIView class]
                              forSupplementaryViewOfKind:supplementaryViewKind
                                     withReuseIdentifier:@"UIView"];
    
    // The data source sould keep track of the prepare block and the reuse identifier.
    XCTAssertEqual((NXCollectionViewDataSourcePrepareBlock)dataSource.supplementaryViewPrepareBlock[supplementaryViewKind], supplementaryViewPrepareBlock);
    XCTAssertEqualObjects(dataSource.supplementaryViewReuseIdentifier[supplementaryViewKind], @"UIView");
}

- (void)testReloadAndPostUpdateBlock
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    NXCollectionViewDataSource *dataSource = [[NXCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    
    __block BOOL postUpdateBlockCalled = NO;
    
    dataSource.postUpdateBlock = ^(NXCollectionViewDataSource *dataSource){
        postUpdateBlockCalled = YES;
    };
    
    [dataSource reload];
    
    [verifyCount(collectionView, times(1)) reloadData];
    XCTAssertTrue(postUpdateBlockCalled);
}

@end
