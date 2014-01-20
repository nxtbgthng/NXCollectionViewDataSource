//
//  NXStaticCollectionViewDataSourceTests.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>

#import "NXStaticCollectionViewDataSource.h"

@interface NXStaticCollectionViewDataSourceTests : XCTestCase
@property (nonatomic, strong) NSArray *sectionNames;
@property (nonatomic, strong) NSArray *sections;
@end

@implementation NXStaticCollectionViewDataSourceTests

- (void)setUp
{
    [super setUp];
    
    self.sectionNames = @[@"Foo", @"Bar", @"Baz"];
    self.sections = @[@[@"Foo_foo", @"Foo_bar", @"Foo_baz"],
                      @[@"Bar_foo", @"Bar_bar", @"Bar_baz"],
                      @[@"Baz_foo", @"Baz_bar", @"Baz_baz"]];
}

#pragma mark Tests

- (void)testSetup
{
    UICollectionView *collectionView = mockClass([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithSections:self.sections
                                                                                                 sectionNames:self.sectionNames
                                                                                            forCollectionView:collectionView];
    
    XCTAssertNotNil(dataSource);
    
    XCTAssertEqualObjects(dataSource.sections, self.sections);
    XCTAssertEqualObjects(dataSource.sectionNames, self.sectionNames);
}

- (void)testGettingItemAndSectionMetrics
{
    UICollectionView *collectionView = mockClass([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithSections:self.sections
                                                                                                 sectionNames:self.sectionNames
                                                                                            forCollectionView:collectionView];
    
    NSInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:collectionView];
    XCTAssertEqual(numberOfSections, 3);
    
    NSInteger numberOfItemsInFirstSection = [dataSource collectionView:collectionView numberOfItemsInSection:0];
    XCTAssertEqual(numberOfItemsInFirstSection, 3);
    
    NSInteger numberOfItemsInSecondSection = [dataSource collectionView:collectionView numberOfItemsInSection:1];
    XCTAssertEqual(numberOfItemsInSecondSection, 3);
    
    NSInteger numberOfItemsInThirdSection = [dataSource collectionView:collectionView numberOfItemsInSection:2];
    XCTAssertEqual(numberOfItemsInThirdSection, 3);
}

@end
