//
//  SessionManager.m
//  Neonan
//
//  Created by capricorn on 12-11-14.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SessionManager.h"
#import "SignController.h"
#import <SSKeychain.h>
#import "SignResult.h"

static NSString *const kServiceName = @"neonan.com";
static NSString *const kAccountKey = @"account";
static NSString *const kPasswordKey = @"password";

@interface SessionManager ()

@property (copy, nonatomic) NSString *token;

- (NSDictionary *)checkAccountInKeyChain;
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

- (void)storeToken:(NSString *)token {
    self.token = token;
}

- (NSString *)getToken {
    return self.token;
}

- (void)requsetToken:(UIViewController *)controller success:(void (^)(NSString *token))success {
    if (_token) {
        if (success) {
            success(_token);
        }
        
        return;
    }
    
    NSDictionary *account = [self checkAccountInKeyChain];
    if (!account) {
        SignController *signController = [[SignController alloc] init];
        signController.success = success;
        [controller.navigationController presentModalViewController:signController animated:YES];
    } else {
        NSString *email = [account objectForKey:kAccountKey];
        NSString *password = [account objectForKey:kPasswordKey];
        [self signWithEmail:email andPassword:password atPath:@"login" success:success failure:nil];
    }
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

- (BOOL)canAutoLogin {
    return [self checkAccountInKeyChain] != nil;
}

- (void)signWithEmail:(NSString *)email
          andPassword:(NSString *)password
               atPath:(NSString *)path
              success:(void (^)(NSString *))success
              failure:(void (^)(ResponseError *error))failure {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil];
    [[NNHttpClient sharedClient] postAtPath:path parameters:parameters responseClass:[SignResult class] success:^(id<Jsonable> response) {
        NSString *token = ((SignResult *)response).token;
        [[SessionManager sharedManager] storeToken:token];
        [SSKeychain setPassword:password forService:kServiceName account:email];
        if (success) {
            success(token);
        }
    } failure:^(ResponseError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)clear {
    self.token = nil;
}

- (void)signOut {
    self.token = nil;
    
    NSArray *accounts = [SSKeychain accountsForService:kServiceName];
    [accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [SSKeychain deletePasswordForService:kServiceName account:[obj objectForKey:kSSKeychainAccountKey]];
    }];
}

@end
