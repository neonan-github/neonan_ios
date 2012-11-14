//
//  SessionManager.h
//  Neonan
//
//  Created by capricorn on 12-11-14.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionManager : NSObject

+ (SessionManager *)sharedManager;

- (void)storeToken:(NSString *)token;
- (void)requsetToken:(UIViewController *)controller success:(void (^)(NSString *token))success;
@end
