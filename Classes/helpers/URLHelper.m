//
//  URLHelper.m
//  Neonan
//
//  Created by capricorn on 13-5-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "URLHelper.h"

#import "AppHelper.h"

@implementation URLHelper

+ (NSURL *)imageURLWithString:(NSString *)URLString {
    if (!URLString) {
        return nil;
    }
    
    NSUInteger totalMemory = NNTotalMemory();
    
    if (totalMemory < 300000000l) { // < 300M, like itouch4, iphone 3gs
        NSRange range = [URLString rangeOfString:@".(?:jpg|gif|png)_\\d+$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            NSString *suffix = [URLString substringWithRange:range];
            DLog(@"image url suffix: %@", suffix);
            
            NSString *sizeInfo = [suffix substringWithRange:[suffix rangeOfString:@"d+$" options:NSRegularExpressionSearch]];
            if (sizeInfo.integerValue > 320) {
                NSString *fileType = [suffix substringWithRange:[suffix rangeOfString:@".(?:jpg|gif|png)" options:NSRegularExpressionSearch]];
                URLString = [[URLString substringToIndex:range.location] stringByAppendingFormat:@"%@_320", fileType];
            }
        } else if ([URLString rangeOfString:@"cdn.neonan.com" options:NSCaseInsensitiveSearch].location != NSNotFound){
            URLString = [URLString stringByAppendingString:@"_212"];
        }
    }
    
    return [NSURL URLWithString:URLString];
}

@end
