//
//  NXFetchedCollectionViewDataSourceTests-FetchLimit.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 22.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>

#import "Person.h"

#import "NXFetchedCollectionViewDataSource.h"

@interface NXFetchedCollectionViewDataSourceTests_FetchLimit : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end

@implementation NXFetchedCollectionViewDataSourceTests_FetchLimit

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

- (void)testFetchLimit
{
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    request.fetchLimit = 10;
    
    for (int i = 0; i < 100; i++) {
        [self insertPersonWithName:[NSString stringWithFormat:@"Persion #%d", i + 10] age:i + 10];
    }
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:nil];
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)1);
    XCTAssertEqual([dataSource numberOfItemsInSection:0], (NSInteger)10);
    
    Person *person = [self insertPersonWithName:@"Persion #0" age:0];
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)1);
    XCTAssertEqual([dataSource numberOfItemsInSection:0], (NSInteger)10);
}

#pragma mark Fixtures

- (Person *)insertPersonWithName:(NSString *)name age:(NSInteger)age
{
    NSEntityDescription *entityDescription = [[self.managedObjectModel entitiesByName] valueForKey:@"Person"];
    
    Person *person = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    person.name = name;
    person.age = age;
    
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, [error localizedDescription]);
    
    return person;
}

@end
