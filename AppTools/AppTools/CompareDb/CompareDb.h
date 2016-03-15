//
//  CompareDb.h
//  AppTools
//
//  Created by buding on 16/3/15.
//  Copyright © 2016年 dingzhiwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompareDb : NSObject

@property (strong, nonatomic) NSString *dbPath1;
@property (strong, nonatomic) NSString *dbPath2;

- (void)compareDb;

@end
