//
//  iOS_saap.m
//  iOS-saap
//
//  Created by Peng Xie on 6/5/13.
//  Copyright (c) 2013 com.sabre.research. All rights reserved.
//

#import "iOS_saap.h"

@implementation iOS_saap

#pragma mark -
#pragma mark Initialization
#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)self didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSLog(@"%@", (NSString *) data);
}


- (void)connection:(NSURLConnection *)self didReceiveResponse:(NSURLResponse *)response {
    // Append the new data to the instance variable you declared
    NSLog(@"======================");
}



- (NSString*) echo: (NSString*)msg {
    return msg;
}


@end
