//
//  EncourageHelper.m
//  Neonan
//
//  Created by capricorn on 13-3-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "EncourageHelper.h"

#import "EncourageModel.h"

@implementation EncourageHelper

+ (void)check:(NSString *)contentId contentType:(NSString *)contentType
   afterDelay:(double)delay should:(BOOL (^)())should success:(void (^)(NSInteger point))success {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (should && should()) {
            [self doEncourage:contentId contentType:contentType success:success];
        }
    });
}

+ (void)doEncourage:(NSString *)contentId
        contentType:(NSString *)contentType
            success:(void (^)(NSInteger))success {
    [[SessionManager sharedManager] requsetToken:nil success:^(NSString *token) {
        NSDictionary *params = @{@"token": token, @"type_id": @"3", @"content_id": contentId, @"content_type": contentType};
        [self doEncourage:params success:success];
    }];
}

+ (void)doEncourage:(NSDictionary *)params success:(void (^)(NSInteger))success {
    [[NNHttpClient sharedClient] getAtPath:kPathAddPoint parameters:params responseClass:[EncourageModel class] success:^(id<Jsonable> response) {
        if (success && [(EncourageModel *)response point] > 0) {
            success([(EncourageModel *)response point]);
        }
    } failure:^(ResponseError *error) {
    }];
}

@end
