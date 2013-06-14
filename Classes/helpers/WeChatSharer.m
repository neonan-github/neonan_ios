//
//  WeChatSharer.m
//  Bang
//
//  Created by capricorn on 13-1-16.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "WeChatSharer.h"

#import <NYXImagesKit.h>

@implementation WeChatSharer

+ (NNSharer *)sharedSharer {
    static NNSharer *_sharedSharer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSharer = [[[self class] alloc] init];
    });
    
    return _sharedSharer;
}

- (NSString *)name {
    return _scene == WXSceneSession ? @"微信好友" : @"微信朋友圈";
}

- (BOOL)isVerified {
    return [WXApi isWXAppInstalled];
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
    self.shareSuccessBlock = success;
    self.shareFailureBlock = failure;
    
    if (self.isVerified) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"NeoNan分享";
        message.description = text;
        
        CGFloat imageSize = MIN(image.size.width, image.size.height);
        [message setThumbImage:[[image cropToSize:CGSizeMake(imageSize, imageSize)] scaleByFactor:100 / imageSize]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = url;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = _scene;
        
        [WXApi sendReq:req];
    } 
}

#pragma mark - WXApiDelegate methods

-(void) onResp:(BaseResp*)resp {
    if (resp.errCode) {
        if (self.shareFailureBlock) {
            self.shareFailureBlock([NSError errorWithDomain:@"com.wechat" code:resp.errCode userInfo:nil]);
        }
        
        return;
    }
   
    if (self.shareSuccessBlock) {
        self.shareSuccessBlock();
    }
}

@end
