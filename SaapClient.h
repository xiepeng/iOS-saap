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
@optional
- (void) dataLoaded: (id) dataJSON;
- (void) failedWithError: (NSError *) error;
@end


@interface SaapClient : NSObject <NSURLConnectionDelegate>

enum SaapAccessProtocol {
    saapHTTP,
    saapHTTPS
};

typedef enum SaapAccessProtocol SaapAccessProtocol;

@property (readonly)        NSString *          endPoint;
@property (readonly)        NSString *          accessKeyId;
@property (readonly)        NSString *          secretKey;
@property (readonly)        SaapAccessProtocol  protocol;
@property (readonly)        NSString *          description;
@property (readonly)        NSString *          signingAlgorithm;
@property (readonly)        NSData   *          responseData;
@property (readonly)        BOOL                isInTheMiddleOfLoading;
@property (readonly, weak)  id <SaapDelegate>   delegate;

- (SaapClient *) initWithEndPoint: (NSString *) endPoint
                      accessKeyId: (NSString *) accessKeyId
                        secretKey: (NSString *) secretKey
                   accessProtocol: (SaapAccessProtocol) protocol
                         delegate: (id <SaapDelegate>) delegate;

- (void) pullRoundTripFlightsFromOrigin: (NSString *) origin
                          toDestination: (NSString *) destination
                        departingOnDate: (NSString *) departureDate
                         returingOnDate: (NSString *) returnDate;

- (void) pullRoundTripFlightsFromOrigin: (NSString *) origin
                          toDestination: (NSString *) destination
                        departingOnDate: (NSString *) departureDate
                         returingOnDate: (NSString *) returnDate
                       topsisPreference: (id) preference;


- (void) pullCalendarLeadPricesFromOrigin: (NSString *) origin
                            toDestination: (NSString *) destination
                      departureDateBegins: (NSString *) departureDateBegin
                        departureDateEnds: (NSString *) departureDateEnd
                             lengthOfStay: (NSInteger) lengthOfStay
                                increment: (NSInteger) increment;

- (void) pullDestinationLeadPricesFromOrigin: (NSString *) origin
                              toDestinations: (NSString *) destinations
                             departingOnDate: (NSString *) departureDate
                             returningOnDate: (NSString *) returnDate;

- (NSMutableURLRequest *) signRequest: (NSMutableURLRequest *) request;

- (void)connectionDidFinishLoading:(NSURLConnection *) conn;
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *) error;

@end
