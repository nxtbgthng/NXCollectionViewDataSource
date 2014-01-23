//
//  NXFetchedCollectionViewDataSourceTests-SectionItems.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 23.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>

#import "Person.h"
#import "Group.h"

#import "NXFetchedCollectionViewDataSource.h"

@interface NXFetchedCollectionViewDataSourceTests_SectionItems : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end

@implementation NXFetchedCollectionViewDataSourceTests_SectionItems

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

- (void)testSectionItems
{
    NSEntityDescription *personEntityDescription = [[self.managedObjectModel entitiesByName] valueForKey:@"Person"];
    NSEntityDescription *groupEntityDescription = [[self.managedObjectModel entitiesByName] valueForKey:@"Group"];
    
    Person *person1 = [[Person alloc] initWithEntity:personEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    person1.name = @"1";
    
    Person *person2 = [[Person alloc] initWithEntity:personEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    person2.name = @"2";
    
    Person *person3 = [[Person alloc] initWithEntity:personEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    person3.name = @"3";
    
    Person *person4 = [[Person alloc] initWithEntity:personEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    person4.name = @"4";
    
    Person *person5 = [[Person alloc] initWithEntity:personEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    person5.name = @"5";

    Person *person6 = [[Person alloc] initWithEntity:personEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    person6.name = @"6";

    Group *groupA = [[Group alloc] initWithEntity:groupEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    groupA.name = @"A";
    groupA.persons = [NSSet setWithObjects:person3, person4, nil];
    
    Group *groupB = [[Group alloc] initWithEntity:groupEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    groupB.name = @"B";
    groupB.persons = [NSSet setWithObjects:person5, person6, nil];
    
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, [error localizedDescription]);
    
    
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"group.name" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:@"group.objectID.URIRepresentation.absoluteString"];
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)3);
    
    XCTAssertEqualObjects([dataSource itemForSection:0], @"");
    XCTAssertEqualObjects([dataSource itemForSection:1], groupA);
    XCTAssertEqualObjects([dataSource itemForSection:2], groupB);
}

@end
