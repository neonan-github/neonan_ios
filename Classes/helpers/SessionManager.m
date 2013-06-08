//
//  SessionManager.m
//  Neonan
//
//  Created by capricorn on 12-11-14.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SessionManager.h"
#import "SignViewController.h"
#import "SignHelper.h"

#import "LoginResult.h"

#import "SinaSigner.h"
#import "TencentSigner.h"
#import "RenRenSigner.h"

#import <SSKeychain.h>
#import <Reachability.h>

static NSString *const kServiceName = @"neonan.com";
static NSString *const kAccountKey = @"account";
static NSString *const kPasswordKey = @"password";
static NSString *const kLoginOptionKey = @"login_option";
static NSString *const kUserInfoKey = @"user_info";

@interface SessionManager ()

@property (nonatomic, copy) NSString *neoId;// neonan uid
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *avatarUrl;

@property (nonatomic, strong) NNSigner *signer;

@end

@implementation SessionManager

+ (SessionManager *)sharedManager {
    static SessionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SessionManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)setAllowAutoLogin:(BOOL)allowAutoLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(allowAutoLogin) forKey:kLoginOptionKey];
    [defaults synchronize];
}

- (BOOL)allowAutoLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [defaults objectForKey:kLoginOptionKey];
    return value ? [value boolValue] : YES;
}

- (BOOL)isLoggedIn {
    return _token != nil;
}

- (BOOL)canAutoLogin {
    //牛男帐号
    NSDictionary *account = [self checkAccountInKeyChain];
    if (!account) {
        //第三方帐号
        account = [SignHelper getAccountInfo:ThirdPlatformNoSpecified];
    }
    
    return _token || (account && [Reachability reachabilityForInternetConnection].isReachable);
}

- (NSString *)getUID {
    return _neoId;
}

- (void)requsetToken:(UIViewController *)controller success:(void (^)(NSString *token))success {
    if (_token) {
        if (success) {
            success(_token);
        }
        
        return;
    }
    
    //牛男帐号
    NSDictionary *account = [self checkAccountInKeyChain];
    if (account) {
        if ([self allowAutoLogin]) {
            NSString *email = [account objectForKey:kAccountKey];
            NSString *password = [account objectForKey:kPasswordKey];
            [self signWithEmail:email andPassword:password atPath:kPathNeoNanLogin success:success failure:^(ResponseError *error) {
                if (error.errorCode < -3) {
                    [UIHelper alertWithMessage:error.message];
                }
            }];
        } else {
            SignViewController *signController = [[SignViewController alloc] init];
            signController.success = success;
            [controller presentModalViewController:signController animated:YES];
        }
        
        return;
    }
    
    //第三方帐号
    account = [SignHelper getAccountInfo:ThirdPlatformNoSpecified];
    if (account) {
        NSString *source = account[kSourceKey];
        NSString *uid = account[kUIDKey];
        [self signWithUID:uid andSource:source andUserName:nil andAvatarUrl:nil success:success failure:^(ResponseError *error) {
            if (error.errorCode < -3) {
                [UIHelper alertWithMessage:error.message];
            }
        }];
    } else {
        SignViewController *signController = [[SignViewController alloc] init];
        signController.success = success;
        [controller presentModalViewController:signController animated:YES];
    }
}

- (void)requsetUserInfo:(UIViewController *)controller
            forceUpdate:(BOOL)forceUpdate
                success:(void (^)(UserInfoModel *info))success
                failure:(void (^)(ResponseError *error))failure {
    if (![self canAutoLogin]) {
        if (success) {
            success(nil);
        }
        return;
    }
    
    void (^requestFromNet)() = ^{
        [[SessionManager sharedManager] requsetToken:controller success:^(NSString *token) {
            [[NNHttpClient sharedClient] getAtPath:kPathGetUserInfo
                                        parameters:@{@"token" : token}
                                     responseClass:[UserInfoModel class]
                                           success:^(id<Jsonable> response) {
                                               [UserDefaults setObject:response forKey:kUserInfoKey];
                                               [UserDefaults synchronize];
                                               
                                               if (success) {
                                                   success((UserInfoModel *)response);
                                               }
                                           }
                                           failure:^(ResponseError *error) {
                                               if (forceUpdate && failure) {
                                                   failure(error);
                                               }
                                           }];
        }];
    };
    
    if (forceUpdate) {
        requestFromNet();
        return;
    }
    
    UserInfoModel *userInfo = [UserDefaults objectForKey:kUserInfoKey];
    if (userInfo) {
        if (success) {
            success(userInfo);
        }
    }
    
    requestFromNet();
}

- (NSDictionary *)checkAccountInKeyChain {
    NSArray *accounts = [SSKeychain accountsForService:kServiceName];
    if (accounts && accounts.count > 0) {
        NSString *email = [[accounts objectAtIndex:0] objectForKey:kSSKeychainAccountKey];
        NSError *error = nil;
        NSString *password = [SSKeychain passwordForService:kServiceName account:email error:&error];
        
        if (!error) {
            return [NSDictionary dictionaryWithObjectsAndKeys:email, kAccountKey, password, kPasswordKey,nil];
        }
    }
    
    return nil;
}

- (void)clear {
    self.token = nil;
}

- (void)logout {
    self.token = nil;
    
    NSArray *accounts = [SSKeychain accountsForService:kServiceName];
    [accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [SSKeychain deletePasswordForService:kServiceName account:[obj objectForKey:kSSKeychainAccountKey]];
    }];
    
    [SignHelper deleteAccounts];
}

- (void)signWithEmail:(NSString *)email
          andPassword:(NSString *)password
               atPath:(NSString *)path
              success:(void (^)(NSString *))success
              failure:(void (^)(ResponseError *error))failure {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil];
    [[NNHttpClient sharedClient] postAtPath:path parameters:parameters responseClass:[LoginResult class] success:^(id<Jsonable> response) {
        LoginResult *result = (LoginResult *)response;
        self.neoId = result.uid;
        self.token = result.token;
        self.userName = result.userName;
        self.avatarUrl = result.avatar;
        
        if (self.allowAutoLogin) {
            [SSKeychain setPassword:password forService:kServiceName account:email];
        }
        
        if (success) {
            success(_token);
        }
    } failure:^(ResponseError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - 3rd Party login

- (void)signWithUID:(NSString *)uid
          andSource:(NSString *)source
        andUserName:(NSString *)userName
       andAvatarUrl:(NSString *)avatar
            success:(void (^)(NSString *token))success
            failure:(void (^)(ResponseError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"uid" : uid, @"source" : source}];
    if (userName) {
        [parameters setObject:userName forKey:@"user_name"];
    }
    if (avatar) {
        [parameters setObject:avatar forKey:@"avatar"];
    }
    
    [[NNHttpClient sharedClient] postAtPath:kPath3rdLogin parameters:parameters responseClass:[LoginResult class] success:^(id<Jsonable> response) {
        LoginResult *result = (LoginResult *)response;
        self.neoId = result.uid;
        self.token = result.token;
        self.userName = result.userName ?: userName;
        self.avatarUrl = result.avatar ?: avatar;
        
        [SignHelper saveAccountWithSource:source andUID:uid andUserName:_userName andAvatar:_avatarUrl];
        
        if (success) {
            success(_token);
        }
    } failure:^(ResponseError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)signWithThirdPlatform:(ThirdPlatformType)platform
           rootViewController:(UIViewController *)controller
                      success:(void (^)(NSString *))success
                      failure:(void (^)(ResponseError *error))failure {
    NNSigner *signer = self.signer = [SignHelper signerWithThirdPlatform:platform];
    signer.showType = ShowTypeModal;
    signer.rootViewController = controller;
    signer.successBlock = ^(NSString *uid, NSString *userName, NSString *avatarUrl) {
        DLog(@"login success:uid:%@ name:%@ avatar:%@", uid, userName, avatarUrl);
        [self signWithUID:uid
                andSource:[SignHelper sourceString:platform]
              andUserName:userName
             andAvatarUrl:avatarUrl
                  success:success
                  failure:failure];
    };
    signer.failureBlock = ^(NSError *error) {
        DLog(@"login fail:%@", [error localizedDescription]);
        if (failure) {
            NSString *errorMessage = [error localizedDescription];
            failure([[ResponseError alloc] initWithCode:ERROR_UNPREDEFINED andMessage:errorMessage]);
        }
    };
    
    [signer login];
}

@end
