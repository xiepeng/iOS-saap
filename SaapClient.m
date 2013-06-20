//
//  SaapClient.m
//  tester
//
//  Created by Peng Xie on 6/12/13.
//  Copyright (c) 2013 com.sabre.research. All rights reserved.
//

#import "SaapClient.h"


@interface SaapClient ();

@property NSMutableURLRequest * req;
@property NSURLConnection *     conn;
@property NSHTTPURLResponse *   res;
@property NSMutableData *       partialData;


+ (NSString *) base64EncodeData: (NSData *) objData;
+ (NSString *) base64EncodeString: (NSString *) strData;

@end

@implementation SaapClient

@synthesize endPoint = _endPoint;
@synthesize accessKeyId = _accessKeyId;
@synthesize secretKey = _secretKey;
@synthesize protocol = _protocol;
@synthesize description = _description;
@synthesize signingAlgorithm = _signingAlgorithm;
@synthesize responseData = _responseData;
@synthesize partialData = _partialData;
@synthesize isInTheMiddleOfLoading = _isInTheMiddleOfLoading;
@synthesize delegate = _delegate;

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

+ (NSString *) base64EncodeString: (NSString *) strData {
	return [self base64EncodeData: [strData dataUsingEncoding: NSUTF8StringEncoding] ];
}

+ (NSString *) base64EncodeData: (NSData *) objData {
	const unsigned char * objRawData = [objData bytes];
	char * objPointer;
	char * strResult;

	// Get the Raw Data length and ensure we actually have data
	int intLength = [objData length];
	if (intLength == 0) return nil;

	// Setup the String-based Result placeholder and pointer within that placeholder
	strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
	objPointer = strResult;

	// Iterate through everything
	while (intLength > 2) { // keep going until we have less than 24 bits
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
		*objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
		*objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];

		// we just handled 3 octets (24 bits) of data
		objRawData += 3;
		intLength -= 3;
	}

	// now deal with the tail end of things
	if (intLength != 0) {
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		if (intLength > 1) {
			*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
			*objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
			*objPointer++ = '=';
		} else {
			*objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
			*objPointer++ = '=';
			*objPointer++ = '=';
		}
	}

	// Terminate the string-based result
	// *objPointer = '\0';
    NSString * resultString = [NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];

    free(strResult);

    // Return the results as an NSString object
	return resultString;
}

- (void)connectionDidFinishLoading:(NSURLConnection *) conn {
    _responseData = [_partialData copy];
    _isInTheMiddleOfLoading = NO;
    // NSLog(@"Finished loading data.");
    NSError * myError = [NSError alloc];

    id jsonData = [[NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&myError] init];
    // NSLog(@"%@", [NSJSONSerialization isValidJSONObject:jsonData]?@"Is valid JSON" : @"Not valid JSON");
    NSLog(@"%@", [[((NSArray *)[jsonData valueForKeyPath:@"FlightSearchRS.Itineraries"]) objectAtIndex:0] valueForKeyPath:@"CurrencyCode"]);
    if ([NSJSONSerialization isValidJSONObject:jsonData]) {
        [self.delegate dataLoaded: jsonData];
    } else {
        [self.delegate failedWithError:[[NSError alloc] initWithDomain:@"InvalidJSON" code:1 userInfo:[[NSDictionary alloc] init]]];
    }
}


- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [_partialData appendData:data];
    // NSLog(@"Received data.");
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSHTTPURLResponse *)response {
    _partialData = [[NSMutableData alloc] init];
    // NSLog(@"Received response.");
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *) error {
    NSLog(@"%@", error);
    _isInTheMiddleOfLoading = NO;
    [self.delegate failedWithError:error];
}


- (SaapClient *) initWithEndPoint: (NSString *) endPoint
                      accessKeyId: (NSString *) accessKeyId
                        secretKey: (NSString *) secretKey
                   accessProtocol: (SaapAccessProtocol) protocol
                         delegate: (id <SaapDelegate>) delegate {
    _delegate = delegate;
    _signingAlgorithm = @"SAAP1-HMAC-SHA256";
    _endPoint    = endPoint;
    _accessKeyId = accessKeyId;
    _secretKey   = secretKey;
    _protocol    = protocol;

    NSLog(@"SaaP client initialized.");
    _description = @"SaapClient:";
    _description = [_description stringByAppendingString: @" endpoint="];
    _description = [_description stringByAppendingString: endPoint];
    _description = [_description stringByAppendingString: @"; protocol="];
    _description = [_description stringByAppendingString: protocol==saapHTTP?@"HTTP":@"HTTPS"];
    _description = [_description stringByAppendingString: @"."];

    NSLog(@"%@", self);
    return self;
}


- (NSMutableURLRequest *) signRequest:(NSMutableURLRequest *)request {

    NSString * path = [[NSString alloc] initWithFormat: @"/%@", [[request.URL.pathComponents subarrayWithRange: NSMakeRange(1, request.URL.pathComponents.count-1)] componentsJoinedByString:@"/"]];
    NSString * method = request.HTTPMethod;
    NSMutableString * stringToSign = [self.signingAlgorithm mutableCopy];
    [stringToSign appendFormat:@"\n%@", method];
    [stringToSign appendFormat:@"\n%@%@", @"host:", self.endPoint];
    [stringToSign appendFormat:@"\n%@%@", @"path:", path];
    [stringToSign appendFormat:@"\n%@%@", @"AccessKeyId:", self.accessKeyId];

    /*
    NSDateFormatter *mmddccyy = [[NSDateFormatter alloc] init];
    mmddccyy.timeStyle = NSDateFormatterNoStyle;
    mmddccyy.dateFormat = @"yyyy-MM-dd'T'HH:mm:SS";
    NSDate * now = [mmddccyy dateFromString:@"2013-06-17T18:55:06"];
    */

    NSDate * now = [[NSDate alloc] init];
    NSTimeZone * utc = [[NSTimeZone alloc] initWithName:@"UTC"];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss' GMT'"];
    [dateFormatter setTimeZone:utc];

    [stringToSign appendFormat:@"\n%@%@", @"Date:", [dateFormatter stringFromDate: now]];
    [stringToSign appendString:@"\n"];

    // NSLog(@"stringToSign=\n%@", stringToSign);

    const char *cKey  = [self.secretKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [stringToSign cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSString * signature = [[self class] base64EncodeData:[NSData dataWithBytes:cHMAC length:CC_SHA256_DIGEST_LENGTH]];

    // NSLog(@"%@", request);
    // NSLog(@"%@", signature);

    [request addValue:[dateFormatter stringFromDate: now]   forHTTPHeaderField:@"x-saap-date"];
    [request addValue:self.accessKeyId                      forHTTPHeaderField:@"x-saap-accesskeyid"];
    [request addValue:signature                             forHTTPHeaderField:@"x-saap-signature"];

    //NSLog(@"%@", request.allHTTPHeaderFields);

    return request;
}

- (void) pullRoundTripFlightsFromOrigin:(NSString *)origin toDestination:(NSString *)destination departingOnDate:(NSString *)departureDate returingOnDate:(NSString *)returnDate {

    [self.conn cancel]; // Cancel any ongoing requests;

    NSMutableString * urlString = [self.protocol==saapHTTPS? @"https://":@"http://" mutableCopy];
    [urlString appendString:self.endPoint];
    [urlString appendString:@"/flights/"];
    [urlString appendString:origin];
    [urlString appendString:@"/"];
    [urlString appendString:destination];
    [urlString appendString:@"/"];
    [urlString appendString:departureDate];
    [urlString appendString:@"/"];
    [urlString appendString:returnDate];
    NSURL * url = [[NSURL alloc] initWithString: urlString];
    self.req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    self.req.HTTPMethod = @"GET";
    self.req  = [self signRequest: self.req];
    self.conn = [[NSURLConnection alloc] initWithRequest:self.req delegate:self];
    _isInTheMiddleOfLoading = YES;
}

- (void) pullCalendarLeadPricesFromOrigin:(NSString *)origin toDestination:(NSString *)destination departureDateBegins:(NSString *)departureDateBegin departureDateEnds:(NSString *)departureDateEnd lengthOfStay:(NSInteger)lengthOfStay increment:(NSInteger)increment {

    [self.conn cancel]; // Cancel any ongoing requests;

    NSMutableString * urlString = [@"http://" mutableCopy];
    [urlString appendString:self.endPoint];
    [urlString appendString:@"/calendar/"];
    [urlString appendString:origin];
    [urlString appendString:@"/"];
    [urlString appendString:destination];
    [urlString appendString:@"?departureDateBegin="];
    [urlString appendString:departureDateBegin];
    [urlString appendString:@"&departureDateEnd="];
    [urlString appendString:departureDateEnd];
    [urlString appendString:@"&lengthOfStay="];
    [urlString appendString:[NSString stringWithFormat:@"%d", lengthOfStay]];
    [urlString appendString:@"&increment="];
    [urlString appendString:[NSString stringWithFormat:@"%d", increment]];
    NSURL * url = [[NSURL alloc] initWithString: urlString];
    self.req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    self.req.HTTPMethod = @"GET";
    self.req  = [self signRequest: self.req];
    self.conn = [[NSURLConnection alloc] initWithRequest:self.req delegate:self];
    _isInTheMiddleOfLoading = YES;
}

- (void) pullDestinationLeadPricesFromOrigin:(NSString *)origin toDestinations: (NSString *) destinations departingOnDate:(NSString *)departureDate returningOnDate:(NSString *)returnDate {

    [self.conn cancel]; // Cancel any ongoing requests;

    NSMutableString * urlString = [@"http://" mutableCopy];
    [urlString appendString:self.endPoint];
    [urlString appendString:@"/destination/"];
    [urlString appendString:origin];
    [urlString appendString:@"/"];
    [urlString appendString:departureDate];
    [urlString appendString:@"/"];
    [urlString appendString:returnDate];
    [urlString appendString:@"?destinations="];
    [urlString appendString:destinations];

    NSURL * url = [[NSURL alloc] initWithString: urlString];
    self.req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    self.req.HTTPMethod = @"GET";
    self.req  = [self signRequest: self.req];
    self.conn = [[NSURLConnection alloc] initWithRequest:self.req delegate:self];
    _isInTheMiddleOfLoading = YES;
}

- (void) pullRoundTripFlightsFromOrigin:(NSString *)origin toDestination:(NSString *)destination departingOnDate:(NSString *)departureDate returingOnDate:(NSString *)returnDate topsisPreference:(id)preference {
    [self pullRoundTripFlightsFromOrigin:origin toDestination:destination departingOnDate:departureDate returingOnDate:returnDate];
}


@end
