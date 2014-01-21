//
//  NXCollectionViewDataSource+Private.h
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXCollectionViewDataSource.h"

extern NSString * const NXCollectionViewDataSourceCellReuseIdentifier;

@interface NXCollectionViewDataSource (Private)

#pragma mark Cells & Supplementary View Prepare Block
@property (nonatomic, readonly) NXCollectionViewDataSourcePrepareBlock cellPrepareBlock;
@property (nonatomic, readonly) NSMutableDictionary *supplementaryViewPrepareBlock;

@end
