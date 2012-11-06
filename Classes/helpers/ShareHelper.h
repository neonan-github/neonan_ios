//
//  ShareHelper.h
//  Neonan
//
//  Created by capricorn on 12-11-6.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareHelper : NSObject <UIActionSheetDelegate>
@property (nonatomic, unsafe_unretained) UIViewController *rootViewController;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (void)showShareView;

@end