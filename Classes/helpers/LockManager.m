//
//  LockManager.m
//  Neonan
//
//  Created by capricorn on 13-7-4.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "LockManager.h"

static NSString *const kVersionKey = @"version";

@implementation LockManager
@synthesize contentLocked = _contentLocked;

+ (LockManager *)sharedManager {
    static LockManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[LockManager alloc] init];
    });
    
    return _sharedManager;
}

- (BOOL)isContentLocked {
    NSString *recordedVersion = [UserDefaults objectForKey:kVersionKey];
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (!recordedVersion || [currentVersion compare:recordedVersion options:NSNumericSearch] == NSOrderedDescending) {
        return YES;
    }
    
    return NO;
}

- (void)validateContentLock {
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
#warning OnlyForTest
    [[NNHttpClient sharedClient] getAtPath:kPath3rdLogin
                                parameters:nil
                             responseClass:nil
                                   success:^(id<Jsonable> response) {
                                       [UserDefaults setObject:currentVersion forKey:kVersionKey];
                                   }
                                   failure:^(ResponseError *error) {
                                    
                                   }];
}

@end
