//
//  NNURLCache.m
//  Neonan
//
//  Created by capricorn on 12-11-20.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNURLCache.h"
#import <DDURLParser.h>

@implementation NNURLCache

+ (NSString *)tokenInUrl:(NSString *)url {
    DDURLParser *parser = [[DDURLParser alloc] initWithURLString:url];
    return [parser valueForVariable:@"token"];
}

// 作为缓存的key，url中不应有token
+ (NSString *)createKeyUrl:(NSString *)url {
    NSString *tokenInUrl = [self tokenInUrl:url];
    if (tokenInUrl) {
        NSRange tokenPrefixRange = [url rangeOfString:@"&token="];
        NSString *newUrl = [url substringToIndex:tokenPrefixRange.location];
        NSString *stringAfter = [url substringFromIndex:tokenPrefixRange.location + tokenPrefixRange.length];
        NSRange tokenEndRange = [stringAfter rangeOfString:@"&"];
        if (tokenEndRange.length > 0) {
            newUrl = [newUrl stringByAppendingString:[stringAfter substringFromIndex:tokenEndRange.location]];
        }
        return newUrl;
    }
    
    return url;
}

+ (NSURLRequest *)createKeyRequest:(NSURLRequest *)request {
    return [NSURLRequest requestWithURL:[NSURL URLWithString:[self createKeyUrl:request.URL.absoluteString]]];
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    if (request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData
        || request.cachePolicy == NSURLRequestReloadIgnoringLocalAndRemoteCacheData
        || request.cachePolicy == NSURLRequestReloadIgnoringCacheData)
    {
        // When cache is ignored for read, it's a good idea not to store the result as well as this option
        // have big chance to be used every times in the future for the same request.
        // NOTE: This is a change regarding default URLCache behavior
        return;
    }
    
    NSURLRequest *keyRequest = [NNURLCache createKeyRequest:request];
    [super storeCachedResponse:cachedResponse forRequest:keyRequest];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    NSLog(@"request url:%@", request.URL.absoluteString);
    return [super cachedResponseForRequest:[NNURLCache createKeyRequest:request]];
}

@end
