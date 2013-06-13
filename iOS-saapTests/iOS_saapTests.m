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
    
    NSLog(@"=========== THE   END ===========");
    [super tearDown];
}

- (void)testExample
{
    NSURL *             myURL = [[NSURL alloc] initWithString:@"http://as.jellyfishsurpriseparty.com/"];
    NSURLRequest *      myRequest = [[NSURLRequest alloc] initWithURL:myURL];
    NSHTTPURLResponse * myResponse = [[NSHTTPURLResponse alloc] init];
    NSError *           myError = [[NSError alloc] init];

    NSData * myData = [iOS_saap sendSynchronousRequest:myRequest returningResponse: &myResponse error:&myError];
    NSString * result = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    NSString * errorDomain = myError.domain;
    NSInteger  errorCode   = myError.code;
    NSString * requestHeader = myRequest.HTTPMethod;
    NSLog(@"%@", requestHeader);
    NSLog(@"%@", result);
    NSLog(@"%@", errorDomain);
    NSLog(@"%d", errorCode);
}

@end
