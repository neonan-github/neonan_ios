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
#import "NNJSONRequestOperation.h"

//#ifdef DEBUG
//static NSString * const kAPIBaseURLString = @"http://192.168.1.114:3000/";
//#else
static NSString * const kAPIBaseURLString = @"http://api.neonan.com/";
//#endif

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

- (BOOL)success:(NSInteger)statusCode {
    return statusCode >= 200 && statusCode < 300;
}

- (void)requestAtPath:(NSString *)path
             byMethod:(NSString *)method
           parameters:(NSDictionary *)parameters
        responseClass:(Class<Jsonable>)responseClass
              success:(void (^)(id<Jsonable> response))success
              failure:(void (^)(ResponseError *error))failure {
    
    DLog(@"request params:%@", parameters);
    
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    request.timeoutInterval = 20;
    NNJSONRequestOperation *operation = [NNJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        DLog(@"response json:%@", JSON);
        
        if ([JSON objectForKey:@"error"]) {
            ResponseError *error = [ResponseError parse:[JSON objectForKey:@"error"]];
            if (failure) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
            
            return;
        }
        
        if (success) {
            id<Jsonable> response = ([JSON allKeys].count < 1) ? nil : (responseClass ? [responseClass parse:JSON] : nil);
            dispatch_sync(dispatch_get_main_queue(), ^{
                success(response);
            });
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            NSString *errorMessage = ([self success:response.statusCode] || response.statusCode == 0) ? [error localizedDescription] : @"网络连接失败";
            failure([[ResponseError alloc] initWithCode:ERROR_UNPREDEFINED andMessage:errorMessage]);
        }
        DLog(@"%@", [error localizedDescription]);
    }];
    
    operation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    operation.allowOfflineMode = [method isEqualToString:@"GET"];
    
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
