//
//  iOS_saapTests.m
//  iOS-saapTests
//
//  Created by Peng Xie on 6/5/13.
//  Copyright (c) 2013 com.sabre.research. All rights reserved.
//

#import "iOS_saapTests.h"
#import "iOS_saap.h"

@implementation iOS_saapTests

- (void)setUp
{
    [super setUp];
    NSLog(@"=========== THE START ===========");

    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    NSLog(@"=========== THE END ===========");
    [super tearDown];
}

- (void)testExample
{
    // STFail(@"Unit tests are not implemented yet in iOS-saapTests");
    iOS_saap* mySaapClient = [[iOS_saap alloc] init];
    NSLog(@"%@", [mySaapClient echo: @"Whut"]);
}

@end
