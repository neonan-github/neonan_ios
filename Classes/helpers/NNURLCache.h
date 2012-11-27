//
//  NNURLCache.h
//  Neonan
//
//  Created by capricorn on 12-11-20.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDURLCache.h"

#ifndef CacheSuperClass
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
    #define CacheSuperClass NSURLCache
#else
    #define CacheSuperClass SDURLCache
#endif
#endif

@interface NNURLCache : CacheSuperClass
+ (NSURLRequest *)createKeyRequest:(NSURLRequest *)request;
@end
