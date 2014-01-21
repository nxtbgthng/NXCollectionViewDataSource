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

@end
