//
//  RenRenSharer.m
//  Bang
//
//  Created by capricorn on 13-1-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "RenRenSharer.h"

#import <SVProgressHUD.h>

@interface RenRenSharer () <RenrenDelegate>

@property (nonatomic, strong) RenRenSigner *signer;

@end

@implementation RenRenSharer

+ (NNSharer *)sharedSharer {
    static NNSharer *_sharedSharer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSharer = [[[self class] alloc] init];
    });
    
    return _sharedSharer;
}

- (NSString *)name {
    return @"人人网";
}

- (BOOL)isVerified {
    Renren *engine = self.signer.engine;
    return engine.isSessionValid;
}

- (void)shareText:(NSString *)text
              url:(NSString *)url
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure {
    [self shareText:text image:nil url:url success:success failure:failure];
}

- (void)shareText:(NSString *)text
            image:(UIImage *)image
              url:(NSString *)url
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure {
    //    Renren *engine = self.signer.engine;
    self.shareSuccessBlock = success;
    self.shareFailureBlock = failure;
    
    NSString *shareContent = [NSString stringWithFormat:@"%@ %@", text, url];
    
    if (self.isVerified) {
        [self postShare:shareContent image:image];
    } else {
        __unsafe_unretained RenRenSharer *weakSelf = self;
        
        _signer.rootViewController = self.rootViewController;
        _signer.successBlock = ^(NSString *uid, NSString *userName, NSString *avatarUrl) {
            [weakSelf postShare:shareContent image:image];
        };
        _signer.failureBlock = ^(NSError *error) {
            if (failure) {
                failure(error);
            }
        };
        [_signer login];
    }
}


#pragma mark - RenrenDelegate -

/**
 * 接口请求成功，第三方开发者实现这个方法
 */
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response {
    if (self.shareSuccessBlock) {
        self.shareSuccessBlock();
    }
}

/**
 * 接口请求失败，第三方开发者实现这个方法
 */
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error {
    if (self.shareFailureBlock) {
        self.shareFailureBlock(error);
    }
}

#pragma mark - Private methods

- (RenRenSigner *)signer {
    if (!_signer) {
        self.signer = [[RenRenSigner alloc] init];
    }
    
    return _signer;
}

- (void)postShare:(NSString *)text image:(UIImage *)image {
    [SVProgressHUD showWithStatus:@"分享中"];
    
    Renren *engine = self.signer.engine;
    if (!image) {
        NSMutableDictionary  *params = [NSMutableDictionary dictionaryWithCapacity:10];
        [params setObject:@"status.set" forKey:@"method"];
        [params setObject:text forKey:@"status"];
        [engine requestWithParams:params andDelegate:self];
    } else {
        ROPublishPhotoRequestParam *param = [[ROPublishPhotoRequestParam alloc] init];
        [param setImageFile:image];
        [param setCaption:text];
        [engine publishPhoto:param andDelegate:self];
    }
}

- (void)postShare:(NSString *)text {
    [self postShare:text image:nil];
}

@end
