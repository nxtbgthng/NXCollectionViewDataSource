//
//  NXHeaderView.m
//  Demo
//
//  Created by Tobias Kräntzer on 23.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXHeaderView.h"

@implementation NXHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _label.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self addSubview:_label];
    }
    return self;
}

- (void)prepareForReuse
{
    self.label.text = nil;
    [super prepareForReuse];
}

@end
