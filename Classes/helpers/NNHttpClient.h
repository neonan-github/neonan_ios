//
//  NNHttpClient.h
//  Neonan
//
//  Created by capricorn on 12-11-1.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <AFNetworking.h>
#import "ResponseError.h"

@interface NNHttpClient : AFHTTPClient

+ (NNHttpClient *)sharedClient;

- (void)postAtPath:(NSString *)path
        parameters:(NSDictionary *)parameters
     responseClass:(Class<Jsonable>)responseClass
           success:(void (^)(id<Jsonable> response))success
           failure:(void (^)(ResponseError *error))failure;

- (void)getAtPath:(NSString *)path
       parameters:(NSDictionary *)parameters
    responseClass:(Class<Jsonable>)responseClass
          success:(void (^)(id<Jsonable> response))success
          failure:(void (^)(ResponseError *error))failure;
@end
