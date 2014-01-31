//
//  NXViewController.m
//  Demo
//
//  Created by Tobias Kräntzer on 23.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <NXCollectionViewDataSource/NXFetchedCollectionViewDataSource.h>

#import "Color.h"
#import "NXHeaderView.h"

#import "NXViewController.h"

@interface NXViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NXFetchedCollectionViewDataSource *dataSource;

#pragma mark CoreData Stack
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@end

@implementation NXViewController

#pragma mark View Life-cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = [[NXFetchedCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                   managedObjectContext:self.managedObjectContext];
    
    [self.dataSource registerClass:[UICollectionViewCell class]
                  withPrepareBlock:^(UICollectionViewCell *cell, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource) {
                      
                      Color *color = [dataSource itemAtIndexPath:indexPath];
                      cell.backgroundColor = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:1];
                      
    }];
    
    [self.dataSource registerClass:[NXHeaderView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                  withPrepareBlock:^(NXHeaderView *view, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource) {
                      
                      NSNumber *selected = [dataSource itemForSection:indexPath.section];
                      
                      if ([selected boolValue]) {
                          view.label.text = @"Selected Colors";
                      } else {
                          view.label.text = @"Other Colors";
                      }
                      
                      view.backgroundColor = [UIColor clearColor];
                      view.label.backgroundColor = [UIColor clearColor];
                      view.label.textColor = [UIColor whiteColor];
                      view.label.textAlignment = NSTextAlignmentCenter;
                      view.label.font = [UIFont boldSystemFontOfSize:22];
                  }];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Color"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"selected" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"red" ascending:NO] ];
    
    NSEntityDescription *colorEntity = [NSEntityDescription entityForName:@"Color"
                                                   inManagedObjectContext:self.managedObjectContext];
    NSAttributeDescription *attribute = [[colorEntity attributesByName] valueForKey:@"selected"];
    
    [self.dataSource reloadWithFetchRequest:request sectionAttributeDescription:attribute];
}

#pragma mark Actions

- (IBAction)addColor:(id)sender
{
    // Create New Color
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Color" inManagedObjectContext:self.managedObjectContext];
    Color *newColor = [[Color alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
 
    newColor.red    = [self randomColorComponentValue];
    newColor.green  = [self randomColorComponentValue];
    newColor.blue   = [self randomColorComponentValue];
    
    // Save Changes
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, [error localizedDescription]);
}

- (IBAction)clear:(id)sender
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Color"];
    request.predicate = [NSPredicate predicateWithFormat:@"selected == NO"];

    NSError *error = nil;
    NSArray *colors = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSAssert(colors, [error localizedDescription]);
    
    [colors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.managedObjectContext deleteObject:obj];
    }];
    
    // Save Changes
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, [error localizedDescription]);
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Delete selected Item
    Color *color = [self.dataSource itemAtIndexPath:indexPath];
    color.selected = !color.selected;
    
    // Save Changes
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, [error localizedDescription]);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(45, 45);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 80);
}

#pragma mark CoreData Stack

@synthesize managedObjectContext = _managedObjectContext;
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _managedObjectContext;
}

@synthesize managedObjectModel = _managedObjectModel;
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil) {
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[Color class]];
        NSURL *modelURL = [frameworkBundle URLForResource:@"DemoModel" withExtension:@"momd"];
        
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error = nil;
        NSPersistentStore *store = [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                                 configuration:nil
                                                                                           URL:nil
                                                                                       options:nil
                                                                                         error:&error];
        NSAssert(store, [error localizedDescription]);
    }
    return _persistentStoreCoordinator;
}

#pragma mark Helper

- (double)randomColorComponentValue
{
    return ((double)arc4random() / 0x100000000);
}

@end
