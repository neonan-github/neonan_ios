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

@property (nonatomic, assign) BOOL allowAutoLogin;

- (BOOL)isLoggedIn;
- (BOOL)canAutoLogin;

- (NSString *)getUID;

- (void)requsetToken:(UIViewController *)controller success:(void (^)(NSString *token))success;// 若token存在，直接返回；否则，请求；

- (void)signWithThirdPlatform:(ThirdPlatformType)platform
           rootViewController:(UIViewController *)controller
                      success:(void (^)(NSString *))success
                      failure:(void (^)(ResponseError *error))failure;

- (void)signWithEmail:(NSString *)email
          andPassword:(NSString *)password
               atPath:(NSString *)path
              success:(void (^)(NSString *))success
              failure:(void (^)(ResponseError *error))failure;

- (void)clear;// 只清除token
- (void)logout;// 注销 清除token和保存的帐号

@end
