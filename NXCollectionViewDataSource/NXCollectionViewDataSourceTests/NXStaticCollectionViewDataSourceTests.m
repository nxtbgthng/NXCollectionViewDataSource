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
#import "NXCollectionViewDataSource+Private.h"

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
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    [dataSource reloadWithSections:self.sections sectionItems:self.sectionNames];
    
    XCTAssertNotNil(dataSource);
    
    XCTAssertEqualObjects(dataSource.sections, self.sections);
    XCTAssertEqualObjects(dataSource.sectionItems, self.sectionNames);
}

- (void)testGettingItemAndSectionMetricsWithoutReload
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    
    NSInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:collectionView];
    XCTAssertEqual(numberOfSections, (NSInteger)0);
}

- (void)testReload
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    [dataSource reloadWithSections:self.sections sectionItems:self.sectionNames];
    
    XCTAssertEqual([dataSource numberOfSectionsInCollectionView:collectionView], (NSInteger)3);
    
    [dataSource reset];
    
    XCTAssertEqual([dataSource numberOfSectionsInCollectionView:collectionView], (NSInteger)0);
}

- (void)testGettingItemAndSectionMetrics
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    [dataSource reloadWithSections:self.sections sectionItems:self.sectionNames];
    
    NSInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:collectionView];
    XCTAssertEqual(numberOfSections, (NSInteger)3);
    
    NSInteger numberOfItemsInFirstSection = [dataSource collectionView:collectionView numberOfItemsInSection:0];
    XCTAssertEqual(numberOfItemsInFirstSection, (NSInteger)3);
    
    NSInteger numberOfItemsInSecondSection = [dataSource collectionView:collectionView numberOfItemsInSection:1];
    XCTAssertEqual(numberOfItemsInSecondSection, (NSInteger)3);
    
    NSInteger numberOfItemsInThirdSection = [dataSource collectionView:collectionView numberOfItemsInSection:2];
    XCTAssertEqual(numberOfItemsInThirdSection, (NSInteger)3);
}

- (void)testGettingItemAndSectionMetricsWithWrongCollectionView
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    [dataSource reloadWithSections:self.sections sectionItems:self.sectionNames];
    
    XCTAssertEqual([dataSource numberOfSectionsInCollectionView:collectionView], (NSInteger)3);
    XCTAssertEqual([dataSource numberOfSectionsInCollectionView:mock([UICollectionView class])], (NSInteger)0);
}

- (void)testGettingItemsAndIndexPaths
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    [dataSource reloadWithSections:self.sections sectionItems:self.sectionNames];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:1];
    NSString *item = @"Bar_baz";
    
    XCTAssertEqualObjects([dataSource itemAtIndexPath:indexPath], item);
    XCTAssertEqualObjects([dataSource indexPathsOfItem:item], @[indexPath]);
}

- (void)testGettingSectionName
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    [dataSource reloadWithSections:self.sections sectionItems:self.sectionNames];
    
    XCTAssertEqualObjects([dataSource itemForSection:0], @"Foo");
    XCTAssertEqualObjects([dataSource itemForSection:1], @"Bar");
    XCTAssertEqualObjects([dataSource itemForSection:2], @"Baz");
}

- (void)testGettingCellForItem
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    [dataSource reloadWithSections:self.sections sectionItems:self.sectionNames];
    
    NSIndexPath *elementIndexPath = [NSIndexPath indexPathForItem:2 inSection:1];
    UICollectionViewCell *elementCell = mock([UICollectionViewCell class]);
    [given([elementCell reuseIdentifier]) willReturn:@"NXCollectionViewDataSourceCellReuseIdentifier"];
    
    __block BOOL prepareBlockCalled = NO;
    
    [dataSource registerClass:[UICollectionViewCell class]
             withPrepareBlock:^(id view, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource) {
                 XCTAssertEqualObjects(indexPath, elementIndexPath);
                 XCTAssertEqual(view, elementCell);
                 prepareBlockCalled = YES;
    }];
    
    [given([collectionView dequeueReusableCellWithReuseIdentifier:NXCollectionViewDataSourceCellReuseIdentifier forIndexPath:elementIndexPath]) willReturn:elementCell];
    
    UICollectionViewCell *cell = [dataSource collectionView:collectionView cellForItemAtIndexPath:elementIndexPath];
    XCTAssertNotNil(cell);
    XCTAssertEqual(cell, elementCell);
    
    XCTAssertTrue(prepareBlockCalled);
}

- (void)testGettingSupplementaryView
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    [dataSource reloadWithSections:self.sections sectionItems:self.sectionNames];
    
    NSString *elementKind = @"kind";
    NSIndexPath *elementIndexPath = [NSIndexPath indexPathForItem:2 inSection:1];
    UICollectionReusableView *elementView = mock([UICollectionReusableView class]);
    [given([elementView reuseIdentifier]) willReturn:elementKind];
    
    __block BOOL prepareBlockCalled = NO;
    
    [dataSource registerClass:[UICollectionReusableView class]
   forSupplementaryViewOfKind:elementKind
             withPrepareBlock:^(id view, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource) {
                 XCTAssertEqualObjects(indexPath, elementIndexPath);
                 XCTAssertEqual(view, elementView);
                 prepareBlockCalled = YES;
    }];
    
    [given([collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:elementKind forIndexPath:elementIndexPath]) willReturn:elementView];
    
    UICollectionReusableView *view = [dataSource collectionView:collectionView viewForSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
    XCTAssertNotNil(view);
    XCTAssertEqual(view, elementView);
    
    XCTAssertTrue(prepareBlockCalled);
}

- (void)testRelaodAndChangeContent
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXStaticCollectionViewDataSource *dataSource = [[NXStaticCollectionViewDataSource alloc] initWithCollectionView:collectionView];
    [dataSource reloadWithSections:self.sections sectionItems:self.sectionNames];
    
    XCTAssertEqual(dataSource.numberOfSections, (NSInteger)3);
    
    [dataSource reloadWithSections:@[@[@"xxx"]] sectionItems:@[@"XXX"]];
    
    XCTAssertEqualObjects(dataSource.sections, @[@[@"xxx"]]);
    XCTAssertEqualObjects(dataSource.sectionItems, @[@"XXX"]);
    
    XCTAssertEqual(dataSource.numberOfSections, (NSInteger)1);
    
    XCTAssertEqualObjects([dataSource itemForSection:0], @"XXX");
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    NSString *item = @"xxx";
    
    XCTAssertEqualObjects([dataSource itemAtIndexPath:indexPath], item);
    XCTAssertEqualObjects([dataSource indexPathsOfItem:item], @[indexPath]);
}

@end
