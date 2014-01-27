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

- (void)testSectionWithAttributeDescription_Number
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
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    
    NSAttributeDescription *attributeDescription = [entityDescription.attributesByName valueForKey:@"age"];
    
    [dataSource reloadWithFetchRequest:request sectionAttributeDescription:attributeDescription];
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)3);
    
    XCTAssertEqualObjects([dataSource itemForSection:0], @(23));
    XCTAssertEqualObjects([dataSource itemForSection:1], @(27));
    XCTAssertEqualObjects([dataSource itemForSection:2], @(35));
}

- (void)testSectionWithAttributeDescription_Date
{
    NSEntityDescription *entityDescription = [[self.managedObjectModel entitiesByName] valueForKey:@"Person"];
    
    NSDate *now = [NSDate date];
    NSDate *later = [NSDate dateWithTimeIntervalSinceNow:60];
    
    Person *peter = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    peter.name = @"Peter";
    peter.age = 23;
    peter.modified = now;
    
    Person *paul = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    paul.name = @"Paul";
    paul.age = 35;
    paul.modified = now;
    
    Person *marry = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    marry.name = @"Marry";
    marry.age = 27;
    marry.modified = later;
    
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, [error localizedDescription]);
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modified" ascending:YES]];
    
    NSAttributeDescription *attributeDescription = [entityDescription.attributesByName valueForKey:@"modified"];
    
    [dataSource reloadWithFetchRequest:request sectionAttributeDescription:attributeDescription];
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)2);
    
    XCTAssertEqualObjects([dataSource itemForSection:0], now);
    XCTAssertEqualObjects([dataSource itemForSection:1], later);
}

- (void)testSectionWithAttributeDescription_double
{
    NSEntityDescription *entityDescription = [[self.managedObjectModel entitiesByName] valueForKey:@"Person"];
    
    Person *peter = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    peter.name = @"Peter";
    peter.rating = 4.7;
    
    Person *paul = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    paul.name = @"Paul";
    paul.rating = 4.7;
    
    Person *marry = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    marry.name = @"Marry";
    marry.rating = 7.9;
    
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, [error localizedDescription]);
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:YES]];
    
    NSAttributeDescription *attributeDescription = [entityDescription.attributesByName valueForKey:@"rating"];
    
    [dataSource reloadWithFetchRequest:request sectionAttributeDescription:attributeDescription];
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)2);
    
    XCTAssertEqualObjects([dataSource itemForSection:0], @(4.7));
    XCTAssertEqualObjects([dataSource itemForSection:1], @(7.9));
}

- (void)testSectionWithAttributeDescription_bool
{
    NSEntityDescription *entityDescription = [[self.managedObjectModel entitiesByName] valueForKey:@"Person"];
    
    Person *peter = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    peter.name = @"Peter";
    peter.female = NO;
    
    Person *paul = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    paul.name = @"Paul";
    paul.female = NO;
    
    Person *marry = [[Person alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    marry.name = @"Marry";
    marry.female = YES;
    
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, [error localizedDescription]);
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"female" ascending:YES]];
    
    NSAttributeDescription *attributeDescription = [entityDescription.attributesByName valueForKey:@"female"];
    
    [dataSource reloadWithFetchRequest:request sectionAttributeDescription:attributeDescription];
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)2);
    
    XCTAssertEqualObjects([dataSource itemForSection:0], @NO);
    XCTAssertEqualObjects([dataSource itemForSection:1], @YES);
}

- (void)testSectionWithAttributeDescription_transient
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
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionKeyPath:@"ageGroup"];
    
    NSAttributeDescription *attributeDescription = [entityDescription.attributesByName valueForKey:@"ageGroup"];
    
    [dataSource reloadWithFetchRequest:request sectionAttributeDescription:attributeDescription];
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)2);
    
    XCTAssertEqualObjects([dataSource itemForSection:0], @20);
    XCTAssertEqualObjects([dataSource itemForSection:1], @30);
    
    XCTAssertEqualObjects([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]], peter);
    XCTAssertEqualObjects([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]], marry);
    XCTAssertEqualObjects([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]], paul);
}

- (void)testSectionsWithRelationshipDescription
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
    
    NSRelationshipDescription *groupRelationshipDescription = [personEntityDescription.relationshipsByName valueForKey:@"group"];
    
    UICollectionView *collectionView = mock([UICollectionView class]);
    
    NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:collectionView managedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"group.name" ascending:YES]];
    
    [dataSource reloadWithFetchRequest:request sectionRelationshipDescription:groupRelationshipDescription];
    
    XCTAssertEqual([dataSource numberOfSections], (NSInteger)3);
    
    XCTAssertEqualObjects([dataSource itemForSection:0], nil);
    XCTAssertEqualObjects([dataSource itemForSection:1], groupA);
    XCTAssertEqualObjects([dataSource itemForSection:2], groupB);
}

@end
