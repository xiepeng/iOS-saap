//
//  iOS_saap.m
//  iOS-saap
//
//  Created by Peng Xie on 6/5/13.
//  Copyright (c) 2013 com.sabre.research. All rights reserved.
//

#import "iOS_saap.h"

@implementation iOS_saap

#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)myConnection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSLog(@"%@", (NSString *) data);
}


- (void)connection:(NSURLConnection *)myConnection didReceiveResponse:(NSURLResponse *)response {
    // Append the new data to the instance variable you declared
    NSLog(@"======================");
}



- (NSString*) echo: (NSString*)msg
{

    NSURL *             myURL = [[NSURL alloc] initWithString:@"http://as.jellyfishsurpriseparty.com/"];
    NSURLRequest *      myRequest = [[NSURLRequest alloc] initWithURL:myURL];

    NSData * myData = [NSURLConnection sendSynchronousRequest:myRequest returningResponse:NULL error:NULL];
    return [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
}


@end
