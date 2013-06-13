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
    iOS_saap * myClient = [[iOS_saap alloc] init];


    NSURL *             myURL = [[NSURL alloc] initWithString:@"http://as.jellyfishsurpriseparty.com/"];
    NSMutableURLRequest * myRequest = [[NSMutableURLRequest alloc] initWithURL:myURL];
    NSHTTPURLResponse * myResponse = [NSHTTPURLResponse alloc];
    NSError *           myError = [NSError alloc];

    myRequest.HTTPMethod = @"GET";
    NSData * myData = [NSURLConnection sendSynchronousRequest:myRequest returningResponse:&myResponse error:&myError];
    NSURLConnection * myConnection = [[NSURLConnection alloc] initWithRequest:myRequest delegate:myClient];

    NSLog(@"%@", [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding]);
    NSLog(@"%@", [NSURLConnection canHandleRequest:myRequest]?@"Yes":@"No");
}

@end
