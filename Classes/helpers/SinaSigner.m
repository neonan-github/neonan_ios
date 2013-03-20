//
//  SinaSigner.m
//  Bang
//
//  Created by capricorn on 12-12-28.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SinaSigner.h"

#import <SVProgressHUD.h>

@interface SinaSigner () <SinaWeiboDelegate, SinaWeiboRequestDelegate>

@property (nonatomic, strong) SinaWeibo *snwbEngine;

@end

@implementation SinaSigner

+ (NNSigner *)signer {
    static NNSigner *_sharedSigner = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSigner = [[SinaSigner alloc] init];
    });
    
    return _sharedSigner;
}

- (id)init {
    self = [super init];
    if (self) {
        self.snwbEngine = [[SinaWeibo alloc] initWithAppKey:kSinaWeiboKey appSecret:kSinaWeiboSecret appRedirectURI:kSinaWeiboRedirectURI andDelegate:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
        if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
        {
            _snwbEngine.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
            _snwbEngine.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
            _snwbEngine.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
        }
    }
    
    return self;
}

- (SinaWeibo *)engine {
    return self.snwbEngine;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
    _snwbEngine.rootViewController = rootViewController;
}

- (void)login {
    if ([_snwbEngine isAuthValid]) {
        [SVProgressHUD showWithStatus:@"登录中"];
        [self getSinaUserInfo:_snwbEngine.userID];
    } else {
        [self logout];
        [_snwbEngine logInWithShowType:self.showType];
    }
}

- (void)logout {
    [self removeAuthData];
    [_snwbEngine logOut];
}

#pragma mark - Private methods

- (void)getSinaUserInfo:(NSString *)uid {
    [_snwbEngine requestWithURL:@"users/show.json"
                             params:[NSMutableDictionary dictionaryWithObject:uid forKey:@"uid"]
                         httpMethod:@"GET"
                           delegate:self];
}

- (void)removeAuthData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)storeAuthData {
    SinaWeibo *sinaweibo = _snwbEngine;
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SinaWeiboDelegate methods

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo {
    [self getSinaUserInfo:sinaweibo.userID];
    
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error {
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

//- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo;
//- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo;
//- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error;

#pragma mark - SinaWeiboRequestDelegate methods

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error {
    [self removeAuthData];
    
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result {
    if ([request.url hasSuffix:@"users/show.json"]) {
        [self storeAuthData];
        
        if (self.successBlock) {
            NSString *uid = _snwbEngine.userID;
            NSString *userName = [result objectForKey:@"screen_name"];
            NSString *avatarUrl = [result objectForKey:@"avatar_large"];
            
            self.successBlock(uid, userName, avatarUrl);
        }
    }
}

@end
