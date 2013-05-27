//
//  ShareEditController.m
//  Neonan
//
//  Created by capricorn on 12-11-6.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ShareEditController.h"

#import <SVProgressHUD.h>

const NSUInteger kMaxInputLimit = 140;

@interface ShareEditController () <UITextViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *bindInfoLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *inputLimitLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *textBgView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *imageBackView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;

@property (unsafe_unretained, nonatomic) UIButton *shareButton;

@end

@implementation ShareEditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.title = @"分享";
    self.view.backgroundColor = DarkThemeColor;
    
    UIButton* backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *navRightButton = self.shareButton = [UIHelper createRightBarButton:@"icon_done_normal.png"];
    [navRightButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    UIImage* textBgImage = [[UIImage imageFromFile:@"bg_share_edit.png"] stretchableImageWithLeftCapWidth:27 topCapHeight:27];
    [_textBgView setImage:textBgImage];
    
    _textView.delegate = self;
    _textView.text = [NSString stringWithFormat:@" // %@", _shareText];
    _textView.selectedRange = NSMakeRange(0, 0);
    
    [self updateLimitHit];
    
    _imageBackView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _imageBackView.layer.borderWidth = 0.5;
//    _imageBackView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
//    _imageBackView.layer.shadowOpacity = 0.8;
//    _imageBackView.layer.shadowOffset = CGSizeMake(0, 2);
    
//    _imageView.layer.borderColor = RGBA(0, 0, 0, 0.3).CGColor;
//    _imageView.layer.borderWidth = 0.5;
    _imageView.image = _shareImage;

}

- (void)cleanUp {
    self.shareButton = nil;
    self.bindInfoLabel = nil;
    self.inputLimitLabel = nil;
    self.textView = nil;
    self.textBgView = nil;
    self.imageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _bindInfoLabel.text = _sharer.isVerified ? @"已绑定" : @"未绑定";
    
    CGRect frame = _textView.frame;
    frame.size.height = self.view.frame.size.height - frame.origin.y - KeyboardPortraitHeight - 10;
    _textView.frame = frame;
    
    frame = _textBgView.frame;
    frame.size.height = _textView.frame.size.height;
    _textBgView.frame = frame;
    
    [_textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    
    [super viewWillDisappear:animated];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateLimitHit];
}

#pragma mark - Private methods

- (void)updateLimitHit {
    NSInteger lengthRemain = kMaxInputLimit - _textView.text.length;
    if (lengthRemain < 0) {
        _inputLimitLabel.text = [NSString stringWithFormat:@"已超%d个字", -lengthRemain];
        _inputLimitLabel.textColor = [UIColor redColor];
        self.shareButton.enabled = NO;
        return;
    }
    
    _inputLimitLabel.text = [NSString stringWithFormat:@"还可输入%d个字", lengthRemain];
    _inputLimitLabel.textColor = [UIColor whiteColor];
    self.shareButton.enabled = YES;
}

- (void)share {
    NSString *text = _textView.text;
    if(!text || [text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"必须指定要分享的内容"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    
    [self.sharer shareText:text image:_shareImage url:_shareUrl success:^{
        [SVProgressHUD showSuccessWithStatus:@"分享成功"];
        [self dismissModalViewControllerAnimated:YES];
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@"" afterDelay:1];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"分享失败"];
    }];
}

@end
