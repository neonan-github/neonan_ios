//
//  EmailSharer.m
//  Bang
//
//  Created by capricorn on 13-1-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "EmailSharer.h"
#import <MessageUI/MessageUI.h>

#import "NNNavigationBar.h"

@interface EmailSharer () <MFMailComposeViewControllerDelegate>

@end

@implementation EmailSharer

+ (NNSharer *)sharedSharer {
    static NNSharer *_sharedSharer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSharer = [[[self class] alloc] init];
    });
    
    return _sharedSharer;
}

- (NSString *)name {
    return @"电子邮件";
}

- (void)shareText:(NSString *)text
              url:(NSString *)url
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure {
    if([MFMailComposeViewController canSendMail]) {
        self.shareSuccessBlock = success;
        self.shareFailureBlock = failure;
        
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        NNNavigationBar *navigationBar = [[NNNavigationBar alloc] init];
        navigationBar.topLineColor = RGB(32, 32, 32);
        navigationBar.bottomLineColor = RGB(32, 32, 32);
        navigationBar.gradientStartColor = RGB(32, 32, 32);
        navigationBar.gradientEndColor = RGB(32, 32, 32);
        navigationBar.tintColor = RGB(32, 32, 32);
        navigationBar.navigationController = mailController;
        [mailController setValue:navigationBar forKeyPath:@"navigationBar"];
        mailController.mailComposeDelegate=self;
        
        [mailController setSubject:text];
        [mailController setMessageBody:[NSString stringWithFormat:@"%@\n%@", text, url] isHTML:NO];
        
        if(self.rootViewController) {
            [self.rootViewController presentModalViewController:mailController animated:YES];
        }
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"请先设置邮件账户" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
    
    if (error || result == MFMailComposeResultFailed) {
        if (self.shareFailureBlock) {
            self.shareFailureBlock(error);
        }
    } else if (result == MFMailComposeResultSent) {
        if (self.shareSuccessBlock) {
            self.shareSuccessBlock();
        }
    }
}

@end
