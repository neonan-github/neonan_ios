//
//  ShareHelper.m
//  Neonan
//
//  Created by capricorn on 12-11-6.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ShareHelper.h"

#import "ShareEditController.h"

#import "SinaSharer.h"
#import "TencentSharer.h"
#import "RenRenSharer.h"
#import "EmailSharer.h"
#import "SmsSharer.h"

#import <SVProgressHUD.h>

static const NSUInteger kWCSessionIndex = 3;
static const NSUInteger kWCTimelineIndex = 4;

@interface ShareHelper () <UIActionSheetDelegate>

@property (nonatomic, unsafe_unretained) UIViewController *rootViewController;

@property (nonatomic, readonly) NSArray *menuItems;
@property (nonatomic, readonly) NSArray *sharerClasses;

@property (nonatomic, strong) NNSharer *sharer;

@end

@implementation ShareHelper

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super init];
    if (self) {
        self.rootViewController = rootViewController;
    }
    return self;
}

- (NSArray *)menuItems {
    return @[@"新浪微博", @"腾讯微博", @"人人网", @"短信分享", @"电子邮件"];
}

- (NSArray *)sharerClasses {
    return @[[SinaSharer class], [TencentSharer class], [RenRenSharer class], [SmsSharer class], [EmailSharer class]];
}

- (void)showShareView {
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [self.menuItems enumerateObjectsUsingBlock:^(NSString *menuText, NSUInteger idx, BOOL *stop) {
        [actionSheet addButtonWithTitle:menuText];
    }];
    
    [actionSheet addButtonWithTitle:@"取消"];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
    [actionSheet showInView:_rootViewController.view];
}

#pragma mark- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex==actionSheet.numberOfButtons - 1) {
        return;
    }
    
    Class sharerClass = self.sharerClasses[buttonIndex];
    NNSharer *sharer = [sharerClass performSelector:@selector(sharedSharer)];
    
    if ([sharer isMemberOfClass:[SmsSharer class]] ||
        [sharer isMemberOfClass:[EmailSharer class]]) {
        self.sharer = sharer;
        sharer.rootViewController = _rootViewController;
        [sharer shareText:_shareText url:_shareUrl success:^{
            [SVProgressHUD showSuccessWithStatus:@"分享成功"];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"分享失败"];
        }];
    }  else {
        ShareEditController *controller = [[ShareEditController alloc] init];
        sharer.rootViewController = controller;
        
        controller.shareText = _shareText;
        controller.shareUrl = _shareUrl;
        controller.shareImage = _shareImage;
        controller.sharer = sharer;
//        controller.title = [NSString stringWithFormat:@"分享到%@", sharer.name];
        [_rootViewController.navigationController pushViewController:controller animated:YES];
    }
}

@end
