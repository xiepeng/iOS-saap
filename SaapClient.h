//
//  SaapClient.h
//  tester
//
//  Created by Peng Xie on 6/12/13.
//  Copyright (c) 2013 com.sabre.research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

@protocol SaapDelegate <NSURLConnectionDelegate>
@end


@interface SaapClient : NSObject <SaapDelegate>

enum SaapAccessProtocol {
    saapHTTP,
    saapHTTPS
};

typedef enum SaapAccessProtocol SaapAccessProtocol;

@property (readonly) NSString * endPoint;
@property (readonly) NSString * accessKeyId;
@property (readonly) NSString * secretKey;
@property (readonly) SaapAccessProtocol protocol;
@property (readonly) NSString * description;
@property (readonly) NSString * signingAlgorithm;
@property (readonly) NSData   * responseData;


- (SaapClient *) initWithEndPoint: (NSString *) endPoint accessKeyId: (NSString *) accessKeyId secretKey:(NSString *) secretKey accessProtocol: (SaapAccessProtocol) protocol;

- (void) pullRoundTripFlightsFromOrigin: (NSString *) origin toDestination: (NSString *) destination departingOnDate: (NSString *) departureDate returingOnDate: (NSString *) returnDate delegate: (id <SaapDelegate>) delegate;

// - (void) pullRoundTripFlightsFromOrigin: (NSString *) origin toDestination: (NSString *) destination departingOnDate: (NSString *) departureDate returingOnDate: (NSString *) returnDate topsisPreference:(id) preference delegate: (id <SaapDelegate>) delegate;


- (void) pullCalendarLeadPricesFromOrigin: (NSString *) origin toDestination: (NSString *) destination departureDateBegins: (NSString *) departureDateBegin departureDateEnds: (NSString *) departureDateEnd lengthOfStay: (NSInteger) lengthOfStay increment: (NSInteger) increment delegate: (id <SaapDelegate>) delegate;

- (void) pullDestinationLeadPricesFromOrigin: (NSString *) origin toDestinations: (NSString *) destinations departingOnDate: (NSString *) departureDate returningOnDate:(NSString *) returnDate delegate:(id <SaapDelegate>) delegate;

- (NSMutableURLRequest *) signRequest:(NSMutableURLRequest *) request;

- (void)connectionDidFinishLoading:(NSURLConnection *) conn;
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *) error;


@end
