//
//  SinaSharer.m
//  Bang
//
//  Created by Wu Yunpeng on 13-1-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "SinaSharer.h"

#import "SinaSigner.h"

#import <SVProgressHUD.h>

@interface SinaSharer () <SinaWeiboRequestDelegate>

@property (nonatomic, strong) SinaSigner *signer;

@end

@implementation SinaSharer

+ (NNSharer *)sharedSharer {
    static NNSharer *_sharedSharer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSharer = [[[self class] alloc] init];
    });
    
    return _sharedSharer;
}

- (NSString *)name {
    return @"新浪微博";
}

- (BOOL)isVerified {
    SinaWeibo *engine = self.signer.engine;
    return engine.isAuthValid;
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
    //    SinaWeibo *engine = self.signer.engine;
    self.shareSuccessBlock = success;
    self.shareFailureBlock = failure;
    
    NSString *shareContent = [NSString stringWithFormat:@"%@ %@", text, url];
    
    if (self.isVerified) {
        [self postShare:shareContent image:image];
    } else {
        __unsafe_unretained SinaSharer *weakSelf = self;
        
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


#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error {
//    if ([request.url hasSuffix:@"statuses/update.json"]) {
        if (self.shareFailureBlock) {
            self.shareFailureBlock(error);
        }
//    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result {
//    if ([request.url hasSuffix:@"statuses/update.json"]) {
        if (self.shareSuccessBlock) {
            self.shareSuccessBlock();
        }
//    }
}

#pragma mark - Private methods

- (SinaSigner *)signer {
    if (!_signer) {
        self.signer = [[SinaSigner alloc] init];
    }
    
    return _signer;
}

- (void)postShare:(NSString *)text image:(UIImage *)image {
    [SVProgressHUD showWithStatus:@"分享中"];
    
    NSString *url = !image ? @"statuses/update.json" : @"statuses/upload.json";
    NSMutableDictionary *params = [(!image ? @{@"status" : text} : @{@"status" : text, @"pic" : image}) mutableCopy];
    
    SinaWeibo *engine = self.signer.engine;
    [engine requestWithURL:url
                    params:params
                httpMethod:@"POST"
                  delegate:self];
}

- (void)postShare:(NSString *)text {
    [self postShare:text image:nil];
}

@end
