//
//  NXCollectionViewDataSource+Private.h
//  NXCollectionViewDataSource
//
//  Created by Tobias Kräntzer on 20.01.14.
//  Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.
//

#import "NXCollectionViewDataSource.h"

@interface NXCollectionViewDataSource (Private)

#pragma mark Collection View Cells
@property (nonatomic, readonly) NSString *cellReuseIdentifier;
@property (nonatomic, readonly) NXCollectionViewDataSourcePrepareBlock cellPrepareBlock;

#pragma mark Collection View Supplementary View
@property (nonatomic, readonly) NSMutableDictionary *supplementaryViewReuseIdentifier;
@property (nonatomic, readonly) NSMutableDictionary *supplementaryViewPrepareBlock;

@end
