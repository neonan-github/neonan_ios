//
//  NNSharer.m
//  Bang
//
//  Created by Wu Yunpeng on 13-1-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNSharer.h"

@implementation NNSharer

+ (NNSharer *)sharedSharer {
    return nil;
}

- (BOOL)isVerified {
    return NO;
}

- (void)shareText:(NSString *)text
              url:(NSString *)url
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure {
    
}

- (void)shareText:(NSString *)text
            image:(UIImage *)image
              url:(NSString *)url
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure {
    
}

@end
