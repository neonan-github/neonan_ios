//
//  SmsSharer.m
//  Bang
//
//  Created by capricorn on 13-1-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "SmsSharer.h"
#import <MessageUI/MessageUI.h>

#import "NNNavigationBar.h"

@interface SmsSharer () <MFMessageComposeViewControllerDelegate>

@end

@implementation SmsSharer

+ (NNSharer *)sharedSharer {
    static NNSharer *_sharedSharer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSharer = [[[self class] alloc] init];
    });
    
    return _sharedSharer;
}

- (NSString *)name {
    return @"短信";
}

- (void)shareText:(NSString *)text
              url:(NSString *)url
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure {
    
    NSString *shareContent = [NSString stringWithFormat:@"%@ %@", text, url];
    
    if(NSClassFromString(@"MFMessageComposeViewController")) {
        
        if([MFMessageComposeViewController canSendText]) {
            self.shareSuccessBlock = success;
            self.shareFailureBlock = failure;
            
            MFMessageComposeViewController *smsController=[[MFMessageComposeViewController alloc] init];
            NNNavigationBar *navigationBar = [[NNNavigationBar alloc] init];
            navigationBar.topLineColor = RGB(32, 32, 32);
            navigationBar.bottomLineColor = RGB(32, 32, 32);
            navigationBar.gradientStartColor = RGB(32, 32, 32);
            navigationBar.gradientEndColor = RGB(32, 32, 32);
            navigationBar.tintColor = RGB(32, 32, 32);
            navigationBar.navigationController = smsController;
            [smsController setValue:navigationBar forKeyPath:@"navigationBar"];
            smsController.messageComposeDelegate = self;
            smsController.body = shareContent;
            
            if(self.rootViewController) {
                [self.rootViewController presentModalViewController:smsController animated:YES];
            }
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"该设备无法发送短信" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", shareContent]]];
    }

}

#pragma mark - MFMessageComposeViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissModalViewControllerAnimated:YES];
    
    if(result == MessageComposeResultSent) {
        if (self.shareSuccessBlock) {
            self.shareSuccessBlock();
        }
    } else if (result == MessageComposeResultFailed) {
        if (self.shareFailureBlock) {
            self.shareFailureBlock(nil);
        }
    }
}

@end
