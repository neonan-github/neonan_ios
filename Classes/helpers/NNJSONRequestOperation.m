//
//  NNJSONRequestOperation.m
//  Neonan
//
//  Created by capricorn on 12-11-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNJSONRequestOperation.h"
#import <Reachability.h>
#import <DDURLParser.h>

@implementation NNJSONRequestOperation

+ (NNJSONRequestOperation *)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NNJSONRequestOperation *requestOperation = [[self alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, operation.response, error, [(AFJSONRequestOperation *)operation responseJSON]);
        }
    }];
    
    return requestOperation;
}

- (NSString *)tokenInUrl:(NSString *)url {
    DDURLParser *parser = [[DDURLParser alloc] initWithURLString:url];
    return [parser valueForVariable:@"token"];
}

- (NSCachedURLResponse *)findCachedResponse:(NSURLRequest *)request {
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (cachedResponse) {
        return cachedResponse;
    }
    
    NSString *url = request.URL.absoluteString;
    NSString *tokenInUrl = [self tokenInUrl:url];
    NSString *newUrl = nil;
    if (tokenInUrl) {
        newUrl = [url stringByReplacingOccurrencesOfString:@"token=.+&" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, url.length)];
        return [[NSURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:newUrl]]];
    }
    
    return nil;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse
{
    if (_allowOfflineMode && ![Reachability reachabilityForInternetConnection].isReachable) {
        NSCachedURLResponse *cachedResponse = [self findCachedResponse:request];
        
        if (cachedResponse) {
            [self setValue:cachedResponse.data forKeyPath:@"responseData"];
            
            [self.outputStream close];
            
            [self performSelector:@selector(finish)];
            
            [self setValue:nil forKeyPath:@"connection"];
            
            return nil;
        }
    }
    
    return [super connection:connection willSendRequest:request redirectResponse:redirectResponse];
}

@end
