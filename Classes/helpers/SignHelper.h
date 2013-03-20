//
//  SignHelper.h
//  Bang
//
//  Created by capricorn on 12-12-28.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SinaSigner.h"
#import "TencentSigner.h"
#import "RenRenSigner.h"

extern NSString *const kSourceKey;
extern NSString *const kUIDKey;
extern NSString *const kUserNameKey;
extern NSString *const kAvatarKey;

// 管理第三方登录
@interface SignHelper : NSObject

+ (NNSigner *)signerWithThirdPlatform:(ThirdPlatformType)platform;
+ (NNSigner *)signerWithSource:(NSString *)source;

+ (NSString *)sourceString:(ThirdPlatformType)platform;

+ (void)saveAccountWithSource:(NSString *)source
                       andUID:(NSString *)uid
                  andUserName:(NSString *)userName
                    andAvatar:(NSString *)avatarUrl;
+ (void)deleteAccounts;

+ (NSDictionary *)getAccountInfo:(ThirdPlatformType)platform;

@end
