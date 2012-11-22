//
//  SessionManager.h
//  Neonan
//
//  Created by capricorn on 12-11-14.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kServiceName;

@interface SessionManager : NSObject

+ (SessionManager *)sharedManager;

- (void)storeToken:(NSString *)token;
- (NSString *)getToken;// 直接返回token，可能为nil
- (void)requsetToken:(UIViewController *)controller success:(void (^)(NSString *token))success;// 若token存在，直接返回；否则，请求；
- (BOOL)canAutoLogin;
- (void)signWithEmail:(NSString *)email
          andPassword:(NSString *)password
               atPath:(NSString *)path
              success:(void (^)(NSString *))success
              failure:(void (^)(ResponseError *error))failure;

- (void)clear;// 只清除token
- (void)signOut;// 注销 清除token和保存的帐号

@end
