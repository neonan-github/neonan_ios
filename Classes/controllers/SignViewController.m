//
//  SignViewController.m
//  Neonan
//
//  Created by Wu Yunpeng on 13-6-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNTextField.h"

#import "SignViewController.h"

#import "MD5.h"
#import "EncourageHelper.h"

#import "EncourageView.h"

#import <SVProgressHUD.h>

@interface SignViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *flipView;

@property (weak, nonatomic) IBOutlet UIImageView *nameBgView0;
@property (weak, nonatomic) IBOutlet UIImageView *passwordBgView0;
@property (weak, nonatomic) IBOutlet UIImageView *nameBgView1;
@property (weak, nonatomic) IBOutlet UIImageView *passwordBgView1;

@property (weak, nonatomic) IBOutlet NNTextField *nameField0;
@property (weak, nonatomic) IBOutlet NNTextField *passwordField0;

@property (weak, nonatomic) IBOutlet NNTextField *nameField1;
@property (weak, nonatomic) IBOutlet NNTextField *passwordField1;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (weak, nonatomic) IBOutlet UIButton *checkBox;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@property (nonatomic, assign) BOOL checkBoxSelected;
@property (nonatomic, assign) SignType signType;

@end

@implementation SignViewController

- (id)init {
    return [self initWithType:SignTypeIn];
}

- (id)initWithType:(SignType)type {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.signType = type;
        self.checkBoxSelected = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *cancelButton = [UIHelper createLeftBarButton:@"icon_nav_close.png"];
    cancelButton.frame = CGRectMake(-2, -2, 50, 50);
    cancelButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    self.flipView.contentSize = CGSizeMake(CompatibleScreenWidth * 2, self.flipView.height);
    
    UIImage *normalBgImage = [[UIImage imageFromFile:@"bg_left_sign_field_normal.png"] stretchableImageWithLeftCapWidth:35
                                                                                                               topCapHeight:27];
    UIImage *highlightedBgImage = [[UIImage imageFromFile:@"bg_left_sign_field_highlighted.png"] stretchableImageWithLeftCapWidth:35
                                                                                                                         topCapHeight:27];
    self.nameBgView0.image = normalBgImage;
    self.nameBgView0.highlightedImage = highlightedBgImage;
    self.passwordBgView0.image = normalBgImage;
    self.passwordBgView0.highlightedImage = highlightedBgImage;
    
    normalBgImage = [[UIImage imageFromFile:@"bg_right_sign_field_normal.png"] stretchableImageWithLeftCapWidth:35
                                                                                                   topCapHeight:27];
    highlightedBgImage = [[UIImage imageFromFile:@"bg_right_sign_field_highlighted.png"] stretchableImageWithLeftCapWidth:35
                                                                                                             topCapHeight:27];
    self.nameBgView1.image = normalBgImage;
    self.nameBgView1.highlightedImage = highlightedBgImage;
    self.passwordBgView1.image = normalBgImage;
    self.passwordBgView1.highlightedImage = highlightedBgImage;
    
    self.checkBox.selected = self.checkBoxSelected;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reset)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self updateLayout:self.signType];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    self.flipView = nil;
    
    self.nameBgView0 = nil;
    self.passwordBgView0 = nil;
    self.nameBgView1 = nil;
    self.passwordBgView1 = nil;
    
    self.nameField0 = nil;
    self.passwordField0 = nil;
    self.nameField1 = nil;
    self.passwordField1 = nil;
    
    self.signUpButton = nil;
    self.signInButton = nil;
    
    self.checkBox = nil;
    self.hintLabel = nil;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    DLog(@"textFieldShouldBeginEditing: %@", textField);
    
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setContentOffset:CGPointMake(0, IS_IPHONE_5 ? 0 : 100) animated:YES];

    if (textField == self.nameField0 || textField == self.nameField1) {
        self.nameBgView0.highlighted = self.nameBgView1.highlighted = YES;
    } else if (textField == self.passwordField0 || textField == self.passwordField1) {
        self.passwordBgView0.highlighted = self.passwordBgView1.highlighted = YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.nameField0 || textField == self.nameField1) {
        self.nameBgView0.highlighted = self.nameBgView1.highlighted = NO;
    } else if (textField == self.passwordField0 || textField == self.passwordField1) {
        self.passwordBgView0.highlighted = self.passwordBgView1.highlighted = NO;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameField0) {
        [self.passwordField0 becomeFirstResponder];
    } else if (textField == self.nameField1) {
        [self.passwordField1 becomeFirstResponder];
    } else {
        [self reset];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.nameField0) {
        self.nameField1.text = newText;
    } else if (textField == self.nameField1) {
        self.nameField0.text = newText;
    } else if (textField == self.passwordField0) {
        self.passwordField1.text = newText;
    } else {
        self.passwordField0.text = newText;
    }
    
    return YES;
}

#pragma mark - Private Event Handle

- (IBAction)onCheckBoxClicked:(id)sender {
    self.checkBoxSelected = !self.checkBoxSelected;
    self.checkBox.selected = self.checkBoxSelected;
}

- (IBAction)onSignUpButtonClicked:(id)sender {
    if (self.signType == SignTypeUp) {
        [self sign];
    } else {
        [self updateLayout:SignTypeUp];
    }
}

- (IBAction)onSignInButtonClicked:(id)sender {
    if (self.signType == SignTypeIn) {
        [self sign];
    } else {
        [self updateLayout:SignTypeIn];
    }
}

#pragma mark - Private methods

- (void)reset {
    [self.nameField0 resignFirstResponder];
    [self.nameField1 resignFirstResponder];
    [self.passwordField0 resignFirstResponder];
    [self.passwordField1 resignFirstResponder];
    
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)updateLayout:(SignType)signType {
    self.signType = signType;
    
    if (signType == SignTypeIn) {
        [self.flipView scrollRectToVisible:CGRectMake(CompatibleScreenWidth, 0, CompatibleScreenWidth, self.flipView.height)
                                  animated:YES];
        [UIView beginAnimations:nil context:NULL];
        self.signUpButton.frame = CGRectMake(-28, 295, 100, 34);
        self.signInButton.frame = CGRectMake(158, 295, 100, 34);
        self.checkBox.x = self.signUpButton.x + 97;
        self.hintLabel.x = self.signUpButton.x + 125;
        [UIView commitAnimations];
    } else {
        [self.flipView scrollRectToVisible:CGRectMake(0, 0, CompatibleScreenWidth, self.flipView.height)
                                  animated:YES];
        [UIView beginAnimations:nil context:NULL];
        self.signUpButton.frame = CGRectMake(64, 295, 100, 34);
        self.signInButton.frame = CGRectMake(248, 295, 100, 34);
        self.checkBox.x = self.signUpButton.x + 97;
        self.hintLabel.x = self.signUpButton.x + 125;
        [UIView commitAnimations];
    }
    
    [self.signUpButton setBackgroundImage:[[UIImage imageFromFile:signType == SignTypeUp ? @"bg_btn_sign_normal.png" : @"bg_btn_sign_disabled.png"]
                                           stretchableImageWithLeftCapWidth:27 topCapHeight:17]
                                 forState:UIControlStateNormal];
    [self.signInButton setBackgroundImage:[[UIImage imageFromFile:signType == SignTypeIn ? @"bg_btn_sign_normal.png" : @"bg_btn_sign_disabled.png"]
                                           stretchableImageWithLeftCapWidth:27 topCapHeight:17]
                                 forState:UIControlStateNormal];

}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)close:(BOOL)delay {
    [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:@"" afterDelay:delay ? 1 : 0];
    
    if (!self.isBeingDismissed) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:@"" afterDelay:delay ? 1.5 : 1];
    }
}

- (BOOL)checkNameField:(UITextField *)nameField {
    NSString *email = [nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!email || email.length < 1) {
        [UIHelper alertWithMessage:@"邮箱不能为空"];
        return NO;
    } else if (![self validateEmail:email]) {
        [UIHelper alertWithMessage:@"邮箱格式错误"];
        return NO;
    }

    return YES;
}

- (BOOL)checkPasswordField:(UITextField *)passwordField {
    NSString *password = [passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!password || password.length < 1) {
        [UIHelper alertWithMessage:@"密码不能为空"];
        return NO;
    }
    
    return YES;
}

- (void)sign {
    if (![self checkNameField:self.nameField0]) {
        return;
    }
    
    if (![self checkPasswordField:self.passwordField0]) {
        return;
    }
    
    NSString *email = [self.nameField0.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField0.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:(self.signType == SignTypeIn ? @selector(signInWithEmail:andPassword:) : @selector(signUpWithEmail:andPassword:))
               withObject:email
               withObject:password];
#pragma clang diagnostic pop
}

- (BOOL)validateEmail:(NSString *)string {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}

- (void)signWithEmail:(NSString *)email andPassword:(NSString *)password atPath:(NSString *)path {
    BOOL signUp = [path rangeOfString:@"login"].location == NSNotFound;
    [SVProgressHUD showWithStatus:signUp ? @"注册中" : @"登录中" maskType:SVProgressHUDMaskTypeClear];
    
    password = [password md5];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    sessionManager.allowAutoLogin = self.checkBox.selected;
    [sessionManager signWithEmail:email andPassword:password atPath:path success:^(NSString *token) {
        if (_success) {
            _success(token);
        }
        
        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
        
        [EncourageHelper doEncourage:@{@"token": token, @"type_id": @(signUp ? 1 : 2)} success:^(NSInteger point) {
            [EncourageView displayScore:point
                                     at:CGPointMake(CompatibleScreenWidth / 2, 100)];
        }];
        
        [self close];
    } failure:^(ResponseError *error) {
        DLog(@"error:%@", error.message);
        [SVProgressHUD dismiss];
        [UIHelper alertWithMessage:error.message];
    }];
}

- (void)signUpWithEmail:(NSString *)email andPassword:(NSString *)password {
    [self signWithEmail:email andPassword:password atPath:kPathNeoNanSignUp];
}

- (void)signInWithEmail:(NSString *)email andPassword:(NSString *)password {
    [self signWithEmail:email andPassword:password atPath:kPathNeoNanLogin];
}

#pragma mark - 3rd Party Login

- (void)login:(ThirdPlatformType)platform {
    [[SessionManager sharedManager] signWithThirdPlatform:platform
                                       rootViewController:self success:^(NSString *token) {
                                           if (_success) {
                                               _success(token);
                                           }
                                           
                                           [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                                           
                                           [EncourageHelper doEncourage:@{@"token": token, @"type_id": @(2)} success:^(NSInteger point) {
                                               [EncourageView displayScore:point
                                                                        at:CGPointMake(CompatibleScreenWidth / 2, 100)];
                                           }];
                                           
                                           [self close:YES];
                                       } failure:^(ResponseError *error) {
                                           DLog(@"error:%@", error.message);
                                           [SVProgressHUD showErrorWithStatus:@"登录失败"];
                                       }];
}

- (IBAction)loginBySina:(id)sender {
    [self login:ThirdPlatformSina];
}

- (IBAction)loginByTencent:(id)sender {
    [self login:ThirdPlatformTencent];
}

@end
