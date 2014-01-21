//
//  NXFetchedCollectionViewDataSourceTests-CollectionViewUpdates.m
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

@interface NXFetchedCollectionViewDataSourceTests_CollectionViewUpdates : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end

@implementation NXFetchedCollectionViewDataSourceTests_CollectionViewUpdates

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

- (void)testUpdateCollectionView
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:window.bounds collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    [window addSubview:collectionView];
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    [dataSource registerClass:[UICollectionViewCell class] withPrepareBlock:^(id view, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource) {}];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:nil];
    
    XCTAssertEqual([collectionView numberOfSections], (NSInteger)1);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], (NSInteger)0);
    
    [self fillContextWithPersons];
    
    XCTAssertEqual([collectionView numberOfSections], (NSInteger)1);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], (NSInteger)3);
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
