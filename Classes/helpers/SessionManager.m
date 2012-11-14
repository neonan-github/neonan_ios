//
//  SessionManager.m
//  Neonan
//
//  Created by capricorn on 12-11-14.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SessionManager.h"
#import "SignController.h"

@interface SessionManager ()

@property (copy, nonatomic) NSString *token;

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

- (void)requsetToken:(UIViewController *)controller success:(void (^)(NSString *token))success {
    if (_token) {
        if (success) {
            success(_token);
        }
        
        return;
    }
    
    SignController *signController = [[SignController alloc] init];
    signController.success = success;
    [controller.navigationController presentModalViewController:signController animated:YES];
}

@end
