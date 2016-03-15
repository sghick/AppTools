//
//  CompareDb.m
//  AppTools
//
//  Created by buding on 16/3/15.
//  Copyright © 2016年 dingzhiwen. All rights reserved.
//

#import "CompareDb.h"
#import "FMDB.h"
#import "TableBata.h"

@implementation CompareDb

- (void)compareDb {
    FMDatabaseQueue *dbQueue1 = [[FMDatabaseQueue alloc] initWithPath:self.dbPath1];
    FMDatabaseQueue *dbQueue2 = [[FMDatabaseQueue alloc] initWithPath:self.dbPath2];
    
    __block NSMutableArray *dbTables1 = [NSMutableArray array];
    __block NSMutableArray *dbTables2 = [NSMutableArray array];
    [dbQueue1 inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"select * from sqlite_master order by rootpage"];
        while ([rs next]) {
            NSDictionary *dict = rs.resultDictionary;
            [dbTables1 addObject:[TableBata instanceWithDictionary:dict]];
        }
    }];
    [dbQueue2 inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"select * from sqlite_master order by rootpage"];
        while ([rs next]) {
            NSDictionary *dict = rs.resultDictionary;
            [dbTables2 addObject:[TableBata instanceWithDictionary:dict]];
        }
    }];
    
    NSMutableArray *moreTables = [NSMutableArray arrayWithArray:dbTables1];
    NSMutableArray *lessTables = [NSMutableArray arrayWithArray:dbTables2];
    NSMutableArray *alterTables1 = [NSMutableArray array];
    NSMutableArray *alterTables2 = [NSMutableArray array];
    
    for (TableBata *bata1 in dbTables1) {
        for (TableBata *bata2 in dbTables2) {
            if ((bata1.type == bata2.type) && ([bata1.name isEqualToString:bata2.name])) {
                if (![bata1.sql isEqualToString:bata2.sql]) {
                    [alterTables1 addObject:bata1];
                    [alterTables2 addObject:bata2];
                }
                [lessTables removeObject:bata2];
                break;
            }
        }
        [moreTables removeObject:bata1];
    }
    
    NSLog(@"TableLessCount:%zi--\n", lessTables.count);
    for (TableBata *bata in lessTables) {
        NSLog(@"\t%@:%@", bata.type, bata.name);
    }
    NSLog(@"TableMoreCount:%zi++\n", moreTables.count);
    for (TableBata *bata in moreTables) {
        NSLog(@"\t%@:%@", bata.type, bata.name);
    }
    NSLog(@"TableAlterCount:%zi-+\n", alterTables1.count);
    for (TableBata *bata in alterTables1) {
        NSLog(@"\t%@:%@", bata.type, bata.name);
        NSInteger idx = [alterTables1 indexOfObject:bata];
        TableBata *bata2 = [alterTables2 objectAtIndex:idx];
        [self compareTableColumnsWithBata1:bata bata2:bata2];
    }
}

- (void)compareTableColumnsWithBata1:(TableBata *)bata1 bata2:(TableBata *)bata2 {
    if (![bata1.name isEqualToString:bata2.name]) {
        NSLog(@"错误,2张表非同一表");
        return;
    }
    NSDictionary *dict1 = [CompareDb sqlColumnsFromCreateSql:bata1.sql];
    NSDictionary *dict2 = [CompareDb sqlColumnsFromCreateSql:bata2.sql];
    if (![dict1 isEqualToDictionary:dict2]) {
        NSMutableArray *moreTables = [NSMutableArray arrayWithArray:dict1.allKeys];
        NSMutableArray *lessTables = [NSMutableArray arrayWithArray:dict2.allKeys];
        NSMutableArray *alterTables = [NSMutableArray array];
        for (NSString *key1 in dict1.allKeys) {
            for (NSString *key2 in dict2.allKeys) {
                if ([key1 isEqualToString:key2]) {
                    if (![dict1[key1] isEqualToString:dict2[key1]]) {
                        [alterTables addObject:key1];
                    }
                    [lessTables removeObject:key1];
                    break;
                }
            }
            [moreTables removeObject:key1];
        }
        NSLog(@"\t\tColumnsLessCount:%zi--\n", lessTables.count);
        for (NSString *key in lessTables) {
            NSLog(@"\t\t\t%@:%@", key, dict2[key]);
        }
        NSLog(@"\t\tColumnsMoreCount:%zi++\n", moreTables.count);
        for (NSString *key in moreTables) {
            NSLog(@"\t\t\t%@:%@", key, dict1[key]);
        }
        NSLog(@"\t\tColumnsAlterCount:%zi-+\n", alterTables.count);
        for (NSString *key in alterTables) {
            NSLog(@"\t\t\t%@:%@ -> %@", key, dict1[key], dict2[key]);
        }
    } else {
        NSLog(@"all equal");
    }
}

+ (NSDictionary *)sqlColumnsFromCreateSql:(NSString *)sql {
    NSAssert([sql.uppercaseString hasPrefix:@"CREATE"], @"sql参数只能是基本的create sql");
    NSString *nSql = [sql copy];
    nSql = [nSql stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    nSql = [nSql stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    nSql = [nSql stringByReplacingOccurrencesOfString:@" \"" withString:@""];
    nSql = [nSql stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSInteger startIndex = [nSql rangeOfString:@"("].location;
    NSInteger endIndex = [nSql rangeOfString:@")"].location;
    if ((startIndex != NSNotFound) && (endIndex != NSNotFound)) {
        NSString *conColumn = [nSql substringWithRange:NSMakeRange(startIndex + 1, endIndex - startIndex - 1)];
        conColumn = [conColumn stringByReplacingOccurrencesOfString:@", " withString:@","];
        NSArray *comColumns = [conColumn componentsSeparatedByString:@","];
        NSMutableDictionary *columns = [NSMutableDictionary dictionary];
        for (NSString *comColumn in comColumns) {
            if ([comColumn hasPrefix:@"PRIMARY KEY"]) {
                continue;
            }
            NSArray *coms = [comColumn componentsSeparatedByString:@" "];
            if (coms.count < 2) {
                NSAssert(NO, @"sql语句错误:%@", sql);
                return nil;
            }
            [columns setObject:coms[1] forKey:coms[0]];
        }
        return columns;
    }
    return nil;
}

@end
