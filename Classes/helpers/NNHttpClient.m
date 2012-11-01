//
//  NNHttpClient.m
//  Neonan
//
//  Created by capricorn on 12-11-1.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNHttpClient.h"
#import <AFJSONRequestOperation.h>

static NSString * const kAPIBaseURLString = @"http://neonan.com:5211/api/";

@implementation NNHttpClient

+ (NNHttpClient *)sharedClient {
    static NNHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NNHttpClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.parameterEncoding = AFJSONParameterEncoding;
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
//	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
