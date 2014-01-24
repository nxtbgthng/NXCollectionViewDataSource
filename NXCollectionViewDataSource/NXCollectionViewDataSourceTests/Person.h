//
//  Person.h
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 21.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic) int32_t age;
@property (nonatomic) BOOL female;

@property (nonatomic) double rating;
@property (nonatomic) NSDate *modified;

@property (nonatomic, readonly) NSString *uppercaseFirstLetterOfName;

@end
