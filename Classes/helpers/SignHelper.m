//
//  SignHelper.m
//  Bang
//
//  Created by capricorn on 12-12-28.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SignHelper.h"

NSString *const kSourceKey = @"source";
NSString *const kUIDKey = @"uid";
NSString *const kUserNameKey = @"userName";
NSString *const kAvatarKey = @"avatar";

@implementation SignHelper

+ (NNSigner *)signerWithThirdPlatform:(ThirdPlatformType)platform {
    switch (platform) {
        case ThirdPlatformSina:
            return [[SinaSigner class] signer];
            
        case ThirdPlatformTencent:
            return [[TencentSigner class] signer];
            
        case ThirdPlatformRenRen:
            return [[RenRenSigner class] signer];
            
        default:
            return nil;
    }
}

+ (NNSigner *)signerWithSource:(NSString *)source {
    NSDictionary *dic = @{kSinaWeiboSource : @(ThirdPlatformSina), kTencentWeiboSource : @(ThirdPlatformTencent), kRenRenSource : @(ThirdPlatformRenRen)};
    return [SignHelper signerWithThirdPlatform:[dic[source] integerValue]];
}

+ (NSString *)sourceString:(ThirdPlatformType)platform {
    switch (platform) {
        case ThirdPlatformSina:
            return kSinaWeiboSource;
            
        case ThirdPlatformTencent:
            return kTencentWeiboSource;
            
        case ThirdPlatformRenRen:
            return kRenRenSource;
            
        default:
            return nil;
    }
}

+ (void)saveAccountWithSource:(NSString *)source
                       andUID:(NSString *)uid
                  andUserName:(NSString *)userName
                    andAvatar:(NSString *)avatarUrl {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@{kUIDKey : uid, kUserNameKey : userName, kAvatarKey : avatarUrl} forKey:source];
    [defaults synchronize];
}

+ (void)deleteAccounts {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [@[kSinaWeiboSource, kTencentWeiboSource, kRenRenSource] enumerateObjectsUsingBlock:^(NSString *source, NSUInteger idx, BOOL *stop) {
        [defaults removeObjectForKey:source];
        NNSigner *signer = [SignHelper signerWithSource:source];
        [signer logout];
    }];
    [defaults synchronize];
}

+ (NSDictionary *)getAccountInfo:(ThirdPlatformType)platform {
    NSString *source = [SignHelper sourceString:platform];
    NSArray *sourcesToCheck = source ? @[source] : @[kSinaWeiboSource, kTencentWeiboSource, kRenRenSource];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (source in sourcesToCheck) {
        NSDictionary *infos = [defaults objectForKey:source];
        if (infos) {
            NSMutableDictionary *results = [infos mutableCopy];
            [results setObject:source forKey:kSourceKey];
            return results;
        }
    }
    
    return nil;
}

@end
