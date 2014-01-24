//
//  NXFetchedCollectionViewDataSourceTests.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 21.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>

#import "Person.h"

#import "NXFetchedCollectionViewDataSource.h"

@interface NXFetchedCollectionViewDataSourceTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end

@implementation NXFetchedCollectionViewDataSourceTests

- (void)setUp
{
    [super setUp];
    
    // Set up in memory store & context
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[Person class]];
    NSURL *modelURL = [frameworkBundle URLForResource:@"Model" withExtension:@"momd"];
    
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError *error = nil;
    NSPersistentStore *store = [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                             configuration:nil
                                                                                       URL:nil
                                                                                   options:nil
                                                                                     error:&error];
    NSAssert(store, [error localizedDescription]);
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
}

#pragma mark Tests

- (void)testSetup
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    XCTAssertNotNil(dataSource);
    
    XCTAssertNotNil(dataSource.managedObjectContext);
    XCTAssertEqual(dataSource.managedObjectContext, self.managedObjectContext);
}

- (void)testRelaodWithFetchRequest
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    XCTAssertNotNil(dataSource);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    
    XCTAssertNoThrow([dataSource reloadWithFetchRequest:request sectionKeyPath:nil]);
    XCTAssertEqualObjects(dataSource.fetchRequest, request);
    XCTAssertNil(dataSource.sectionKeyPath);
}

- (void)testRelaodWithInvalidFetchRequest
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    XCTAssertNotNil(dataSource);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    
    XCTAssertThrowsSpecificNamed([dataSource reloadWithFetchRequest:request sectionKeyPath:nil], NSException, @"NSInvalidArgumentException");
}

- (void)testReset
{
    [self fillContextWithPersons];
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    XCTAssertNotNil(dataSource);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:nil];
    
    XCTAssertEqual([dataSource numberOfSectionsInCollectionView:collectionView], 1);
    XCTAssertEqual([dataSource collectionView:collectionView numberOfItemsInSection:0], 3);
    
    [dataSource reset];
    
    XCTAssertEqual([dataSource numberOfSectionsInCollectionView:collectionView], 0);
}

- (void)testGettingItemAndSectionMetrics
{
    [self fillContextWithPersons];
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:nil];
    
    NSInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:collectionView];
    XCTAssertEqual(numberOfSections, 1);
    
    NSInteger numberOfItemsInFirstSection = [dataSource collectionView:collectionView numberOfItemsInSection:0];
    XCTAssertEqual(numberOfItemsInFirstSection, 3);
}

- (void)testGettingItemAndSectionMetricsWithSectionKeyPath
{
    [self fillContextWithPersons];
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:@"uppercaseFirstLetterOfName"];
    
    NSInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:collectionView];
    XCTAssertEqual(numberOfSections, 2);
    
    XCTAssertEqual([dataSource collectionView:collectionView numberOfItemsInSection:0], 1);
    XCTAssertEqual([dataSource collectionView:collectionView numberOfItemsInSection:1], 2);
}

- (void)testGettingItemsAndIndexPaths
{
    [self fillContextWithPersons];
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:nil];
    
    Person *peter = [dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertEqualObjects(peter.name, @"Peter");
    
    Person *marry = [dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    XCTAssertEqualObjects(marry.name, @"Marry");
    
    Person *paul = [dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    XCTAssertEqualObjects(paul.name, @"Paul");
}

- (void)testGettingSectionName
{
    [self fillContextWithPersons];
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:@"uppercaseFirstLetterOfName"];
    
    NSInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:collectionView];
    XCTAssertEqual(numberOfSections, 2);
    
    XCTAssertEqualObjects([dataSource itemForSection:0], @"M");
    XCTAssertEqualObjects([dataSource itemForSection:1], @"P");
}

- (void)testUpdatingItems
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    __block NSInteger numberOfTimesPostUpdateBlockHasBeenCalled = 0;
    dataSource.postUpdateBlock = ^(NXCollectionViewDataSource *dataSource){ numberOfTimesPostUpdateBlockHasBeenCalled++; };
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:nil];
    XCTAssertEqual(numberOfTimesPostUpdateBlockHasBeenCalled, (NSInteger)1);
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)1);
    XCTAssertEqual([dataSource numberOfItemsInSection:0], (NSInteger)0);
    
    [self fillContextWithPersons];
    XCTAssertEqual(numberOfTimesPostUpdateBlockHasBeenCalled, (NSInteger)2);
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)1);
    XCTAssertEqual([dataSource numberOfItemsInSection:0], (NSInteger)3);
}

#pragma mark Fixtures

- (void)fillContextWithPersons
{
    NSEntityDescription *entityDescription = [[self.managedObjectModel entitiesByName] valueForKey:@"Person"];
    
    Person *peter = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    peter.name = @"Peter";
    peter.age = 23;
    
    Person *paul = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    paul.name = @"Paul";
    paul.age = 35;
    
    Person *marry = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    marry.name = @"Marry";
    marry.age = 27;
    
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, [error localizedDescription]);
}

@end
