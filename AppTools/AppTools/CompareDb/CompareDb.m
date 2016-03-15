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
    NSMutableArray *lessTables = [NSMutableArray array];
    NSMutableArray *alterTables = [NSMutableArray array];
    
    for (TableBata *bata1 in dbTables1) {
        for (TableBata *bata2 in dbTables2) {
            if ((bata1.type == bata2.type) && ([bata1.name isEqualToString:bata2.name])) {
                if (![bata1.sql isEqualToString:bata2.sql]) {
                    [alterTables addObject:bata1];
                }
                [dbTables2 removeObject:bata2];
                break;
            }
        }
        [moreTables removeObject:bata1];
    }
    [lessTables addObjectsFromArray:dbTables2];
    
    NSLog(@"lessTableCount:%zi--\n", lessTables.count);
    for (TableBata *bata1 in lessTables) {
        NSLog(@"%@", bata1.name);
    }
    NSLog(@"moreTableCount:%zi++\n", moreTables.count);
    for (TableBata *bata2 in moreTables) {
        NSLog(@"%@", bata2.name);
    }
    NSLog(@"alterTableCount:%zi-+\n", alterTables.count);
    for (TableBata *bata3 in alterTables) {
        NSLog(@"%@", bata3.name);
    }
}

@end
