//
//  TencentSigner.m
//  Bang
//
//  Created by capricorn on 12-12-28.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "TencentSigner.h"

@interface TencentSigner ()

@property (nonatomic, strong) TCWBEngine *tcwbEngine;

@end

@implementation TencentSigner

+ (NNSigner *)signer {
    static NNSigner *_sharedSigner = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSigner = [[TencentSigner alloc] init];
    });
    
    return _sharedSigner;
}

- (id)init {
    self = [super init];
    if (self) {
        self.tcwbEngine = [[TCWBEngine alloc] initWithAppKey:kTencentWeiboKey andSecret:kTencentWeiboSecret andRedirectUrl:kTencentWeiboRedirectURI];
    }
    
    return self;
}

- (TCWBEngine *)engine {
    return self.tcwbEngine;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
    _tcwbEngine.rootViewController = rootViewController;
}

- (void)login {
    if ([_tcwbEngine isLoggedIn] && ![_tcwbEngine isAuthorizeExpired]) {
        [self onTCWBSuccessLogin];
    } else {
        [self logout];
        [self.tcwbEngine logInWithDelegate:self
                               andShowType:ShowTypePush
                                 onSuccess:@selector(onTCWBSuccessLogin)
                                 onFailure:@selector(onTCWBFailureLogin:)];
    }
}

- (void)logout {
    [_tcwbEngine logOut];
}

#pragma mark - Private methods

- (void)onTCWBSuccessLogin {
    [self.tcwbEngine getUserInfoWithFormat:@"json"
                               parReserved:nil
                                  delegate:self
                                 onSuccess:@selector(onGetTCWBUserInfo:)
                                 onFailure:@selector(onTCWBFailureLogin:)];
}

- (void)onTCWBFailureLogin:(NSError *)error {
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

- (void)onGetTCWBUserInfo:(NSDictionary *)userInfo {
    if (self.successBlock) {
        NSString *uid = self.tcwbEngine.openId;
        NSString *userName = userInfo[@"data"][@"nick"];
        NSString *avatarUrl = [userInfo[@"data"][@"head"] stringByAppendingString:@"/50"];
        
        self.successBlock(uid, userName, avatarUrl);
    }
}

@end
