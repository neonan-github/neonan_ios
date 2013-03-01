//
//  NNSharer.h
//  Bang
//
//  Created by Wu Yunpeng on 13-1-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNSharer : NSObject

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, unsafe_unretained) UIViewController *rootViewController;

@property (nonatomic, copy) void (^shareSuccessBlock)(void);
@property (nonatomic, copy) void (^shareFailureBlock)(NSError *error);

+ (NNSharer *)sharedSharer;

- (BOOL)isVerified;

- (void)shareText:(NSString *)text
              url:(NSString *)url
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure;

- (void)shareText:(NSString *)text
            image:(UIImage *)image
              url:(NSString *)url
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure;

@end
