//
//  TableBata.h
//  AppTools
//
//  Created by buding on 16/3/15.
//  Copyright © 2016年 dingzhiwen. All rights reserved.
//

#import "SMModel.h"

@interface TableBata : SMModel

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *tbl_name;
@property (assign, nonatomic) int32_t  rootpage;
@property (strong, nonatomic) NSString *sql;

@end
