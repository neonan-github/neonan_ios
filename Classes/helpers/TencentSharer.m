//
//  TencentSharer.m
//  Bang
//
//  Created by capricorn on 13-1-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "TencentSharer.h"

#import "TencentSigner.h"

#import <SVProgressHUD.h>

@interface TencentSharer ()

@property (nonatomic, strong) TencentSigner *signer;

@end

@implementation TencentSharer

+ (NNSharer *)sharedSharer {
    static NNSharer *_sharedSharer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSharer = [[[self class] alloc] init];
    });
    
    return _sharedSharer;
}

- (NSString *)name {
    return @"腾讯微博";
}

- (BOOL)isVerified {
    TCWBEngine *engine = self.signer.engine;
    return engine.isLoggedIn && !engine.isAuthorizeExpired;
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
    //    TCWBEngine *engine = self.signer.engine;
    self.shareSuccessBlock = success;
    self.shareFailureBlock = failure;
    
    NSString *shareContent = [NSString stringWithFormat:@"%@ %@", text, url];
    
    if (self.isVerified) {
        [self postShare:shareContent image:image];
    } else {
        __unsafe_unretained TencentSharer *weakSelf = self;
        
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

#pragma mark - Private methods

- (TencentSigner *)signer {
    if (!_signer) {
        self.signer = [[TencentSigner alloc] init];
    }
    
    return _signer;
}

- (void)postShare:(NSString *)text image:(UIImage *)image {
    [SVProgressHUD showWithStatus:@"分享中"];
    
    TCWBEngine *engine = self.signer.engine;
    if (image) {
        [engine postPictureTweetWithFormat:@"json"
                                   content:text
                                  clientIP:@"10.10.1.31"
                                       pic:UIImageJPEGRepresentation(image, 0.8)
                            compatibleFlag:@"0"
                                 longitude:nil
                               andLatitude:nil
                               parReserved:nil
                                  delegate:self
                                 onSuccess:@selector(successCallBack:)
                                 onFailure:@selector(failureCallBack:)];
    } else {
        [engine postTextTweetWithFormat:@"json"
                                content:text
                               clientIP:@"10.10.1.31"
                              longitude:nil
                            andLatitude:nil
                            parReserved:nil
                               delegate:self
                              onSuccess:@selector(successCallBack:)
                              onFailure:@selector(failureCallBack:)];
    }
}

- (void)postShare:(NSString *)text {
    [self postShare:text image:nil];
}

- (void)successCallBack:(id)result{
    if (self.shareSuccessBlock) {
        self.shareSuccessBlock();
    }
}

- (void)failureCallBack:(NSError *)error{
    if (self.shareFailureBlock) {
        self.shareFailureBlock(error);
    }
}


@end
