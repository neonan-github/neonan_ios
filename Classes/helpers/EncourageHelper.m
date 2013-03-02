//
//  EncourageHelper.m
//  Neonan
//
//  Created by capricorn on 13-3-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "EncourageHelper.h"

@implementation EncourageHelper

+ (void)check:(NSString *)contentId contentType:(NSString *)contentType
   afterDelay:(double)delay should:(BOOL (^)())should success:(void (^)())success {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (should && should()) {
            [self doEncourage:contentId contentType:contentType success:success];
        }
    });
}

+ (void)doEncourage:(NSString *)contentId
        contentType:(NSString *)contentType
            success:(void (^)())success {
    if (success) {
        success();
    }
}

@end
