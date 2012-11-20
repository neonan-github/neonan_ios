//
//  NNURLCache.h
//  Neonan
//
//  Created by capricorn on 12-11-20.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNURLCache : NSURLCache
+ (NSURLRequest *)createKeyRequest:(NSURLRequest *)request;
@end
