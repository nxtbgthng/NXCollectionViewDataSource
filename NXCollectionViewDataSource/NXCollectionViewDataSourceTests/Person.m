//
//  Person.m
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 21.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "Person.h"


@implementation Person

@dynamic name;
@dynamic age;
@dynamic female;
@dynamic rating;
@dynamic modified;

- (NSString *)uppercaseFirstLetterOfName
{
    NSString *uppercaseName = [self.name uppercaseString];
    return [uppercaseName substringWithRange:[uppercaseName rangeOfComposedCharacterSequenceAtIndex:0]];
}

- (int32_t)ageGroup
{
    int32_t age = self.age;
    return floor(age / 10.0) * 10;
}

@end
