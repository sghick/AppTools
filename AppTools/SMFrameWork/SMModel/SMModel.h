//
//  SMModel.h
//  Demo-SMFrameWork
//
//  Created by 丁治文 on 15/8/8.
//  Copyright (c) 2015年 buding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSUserDefaults+SMModel.h"

@interface SMModel : NSObject <
    NSCoding
>

@property (strong, nonatomic) NSArray *allKeys;

- (NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFormateToString:(NSDictionary *)dict;

+ (instancetype)instanceWithDictionary:(NSDictionary *)dict;
+ (instancetype)instanceWithDictionary:(NSDictionary *)dict key:(NSString *)key;
+ (NSArray *)arrayWithDictionary:(NSDictionary *)dict;
+ (NSArray *)arrayWithDictionary:(NSDictionary *)dict key:(NSString *)key;

// override for sub class
+ (NSMutableDictionary *)classNameMapper;

#pragma mark - 归档
- (NSData *)data;
+ (NSData *)dataFromModel:(SMModel *)model;
+ (instancetype)modelFromData:(NSData *)data;

@end
