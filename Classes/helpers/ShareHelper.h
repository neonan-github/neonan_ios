//
//  ShareHelper.h
//  Neonan
//
//  Created by capricorn on 12-11-6.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareHelper : NSObject

@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, copy) NSString *shareText;
@property (nonatomic, strong) UIImage *shareImage;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (void)showShareView;

@end