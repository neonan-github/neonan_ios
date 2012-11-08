//
//  NNHttpClient.m
//  Neonan
//
//  Created by capricorn on 12-11-1.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNHttpClient.h"
#import <AFJSONRequestOperation.h>
#import "ResponseError.h"

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

- (void)requestAtPath:(NSString *)path
             byMethod:(NSString *)method
           parameters:(NSDictionary *)parameters
        responseClass:(Class<Jsonable>)responseClass
              success:(void (^)(id<Jsonable> response))success
              failure:(void (^)(ResponseError *error))failure {
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([JSON objectForKey:@"error"]) {
            ResponseError *error = [ResponseError parse:[JSON objectForKey:@"error"]];
            if (failure) {
                failure(error);
            }
            
            return;
        }
        
        if (success) {
            success([responseClass parse:JSON]);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure([[ResponseError alloc] initWithCode:0 andMessage:[error localizedDescription]]);
        }
        NSLog(@"%@", [error localizedDescription]);
    }];
    [operation start];
}

- (void)postAtPath:(NSString *)path
         parameters:(NSDictionary *)parameters
      responseClass:(Class<Jsonable>)responseClass
            success:(void (^)(id<Jsonable> response))success
            failure:(void (^)(ResponseError *error))failure {
    [self requestAtPath:path byMethod:@"POST" parameters:parameters responseClass:responseClass success:success failure:failure];
}

- (void)getAtPath:(NSString *)path
        parameters:(NSDictionary *)parameters
     responseClass:(Class<Jsonable>)responseClass
           success:(void (^)(id<Jsonable> response))success
           failure:(void (^)(ResponseError *error))failure {
    [self requestAtPath:path byMethod:@"GET" parameters:parameters responseClass:responseClass success:success failure:failure];
}

@end
