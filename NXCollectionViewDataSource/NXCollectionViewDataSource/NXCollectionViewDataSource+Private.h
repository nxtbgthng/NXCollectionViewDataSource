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

#pragma mark Cell Predicates & Prepare Blocks
@property (nonatomic, readonly) NSMutableDictionary *predicates;
@property (nonatomic, readonly) NSMutableDictionary *prepareBlocks;

#pragma mark Supplementary View Prepare Block
@property (nonatomic, readonly) NSMutableDictionary *supplementaryViewPrepareBlock;

@end
