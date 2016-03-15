//
//  ViewController.m
//  AppTools
//
//  Created by buding on 16/3/15.
//  Copyright © 2016年 dingzhiwen. All rights reserved.
//

#import "ViewController.h"
#import "CompareDb.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CompareDb *cp = [[CompareDb alloc] init];
    cp.dbPath1 = @"/Users/buding/Desktop/DB1.sqlite";
    cp.dbPath2 = @"/Users/buding/Desktop/DB2.sqlite";
    [cp compareDb];
}


@end
