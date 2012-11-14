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
- (NSString *)getToken;// 直接返回token
- (void)requsetToken:(UIViewController *)controller success:(void (^)(NSString *token))success;// 若token，存在直接返回；否则，请求；
@end
