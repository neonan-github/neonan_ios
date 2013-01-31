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

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path {
    if ((self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path])) {

    }
    
    return self;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    NSURLRequest *keyRequest = [NNURLCache createKeyRequest:request];
    [super storeCachedResponse:cachedResponse forRequest:keyRequest];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    return [super cachedResponseForRequest:[NNURLCache createKeyRequest:request]];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    NSURLRequest *keyRequest = [NNURLCache createKeyRequest:request];
    [super removeCachedResponseForRequest:keyRequest];
}

@end
