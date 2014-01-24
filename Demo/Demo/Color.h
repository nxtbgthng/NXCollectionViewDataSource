//
//  Color.h
//  Demo
//
//  Created by Tobias Kräntzer on 23.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Color : NSManagedObject

@property (nonatomic) double red;
@property (nonatomic) double green;
@property (nonatomic) double blue;

@property (nonatomic) BOOL selected;

@end
