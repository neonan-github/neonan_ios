//
//  NNSigner.h
//  Bang
//
//  Created by capricorn on 12-12-28.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock)(NSString *uid, NSString *userName, NSString *avatarUrl);
typedef void(^FailureBlock)(NSError *error);

@interface NNSigner : NSObject

@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) FailureBlock failureBlock;

+ (NNSigner *)signer;
- (void)login;
- (void)logout;

@end
