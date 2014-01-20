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

@interface NXCollectionViewDataSourceTests : XCTestCase

@end

@implementation NXCollectionViewDataSourceTests

#pragma mark Tests

- (void)testSetup
{
    UICollectionView *collectionView = mockClass([UICollectionView class]);
    
    NXCollectionViewDataSource *dataSource = [[NXCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    
    XCTAssertNotNil(dataSource);
    XCTAssertEqual(dataSource.collectionView, collectionView);
}

@end
