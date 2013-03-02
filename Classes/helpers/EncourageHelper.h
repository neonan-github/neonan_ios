//
//  EncourageHelper.h
//  Neonan
//
//  Created by capricorn on 13-3-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncourageHelper : NSObject

+ (void)check:(NSString *)contentId contentType:(NSString *)contentType
   afterDelay:(double)delay should:(BOOL (^)())should success:(void (^)())success;

@end
