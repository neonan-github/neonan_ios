//
//  SignController.m
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SignController.h"
#import "NNNavigationController.h"

#import "LoginResult.h"

#import "SessionManager.h"
#import "MD5.h"

#import "EncourageView.h"
#import "NNUnderlinedButton.h"

#import <DCRoundSwitch.h>
#import <SSKeychain.h>
#import <SVProgressHUD.h>

@interface SignController ()
@property (unsafe_unretained, nonatomic) NNUnderlinedButton *switchTypeButton;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *userTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *passwordTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *actionButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *rememberPWLabel;
@property (unsafe_unretained, nonatomic) IBOutlet DCRoundSwitch *rememberSwitch;

- (BOOL)validateEmail:(NSString *)string;
- (void)signUpWithEmail:(NSString *)email andPassword:(NSString *)password;
- (void)signInWithEmail:(NSString *)email andPassword:(NSString *)password;

@end

@implementation SignController

- (id)initWithType:(signType)type {
    self = [super init];
    if (self) {
        // Custom initialization
        _type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *cancelButton = [UIHelper createLeftBarButton:@"icon_close_normal.png"];
    cancelButton.frame = CGRectMake(14, 8, 30, 30);
    cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    self.view.backgroundColor = DarkThemeColor;
    
    [_actionButton addTarget:self action:@selector(sign:) forControlEvents:UIControlEventTouchUpInside];
    
    NNUnderlinedButton *switchTypeButton = self.switchTypeButton = [[NNUnderlinedButton alloc] initWithFrame:CGRectMake(250, -2, 67, 50)];
    switchTypeButton.titleLabel.font = [UIFont systemFontOfSize:18];
    switchTypeButton.backgroundColor = [UIColor clearColor];
    [switchTypeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [switchTypeButton setTitleColor:HEXCOLOR(0x16a1e8) forState:UIControlStateHighlighted];
    [switchTypeButton addTarget:self action:@selector(switchType) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchTypeButton];
    
    self.type = _type;
    
    _rememberSwitch.on = YES;
    _rememberSwitch.onText = @"";
    _rememberSwitch.offText = @"";
}

- (void)cleanUp {
    self.switchTypeButton = nil;
    self.userTextField = nil;
    self.passwordTextField = nil;
    self.actionButton = nil;
    self.rememberPWLabel = nil;
    self.rememberSwitch = nil;
}

#pragma mark - UIViewController life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setType:(signType)type {
    _type = type;
    
    [_switchTypeButton setTitle:(_type == signUp ? @"登录" : @"注册") forState:UIControlStateNormal];
    [_actionButton setTitle:(_type == signIn ? @"登录" : @"注册") forState:UIControlStateNormal];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(_type == signIn ? @"注册" : @"登录")
//                                                                              style:UIBarButtonItemStylePlain
//                                                                             target:self
//                                                                             action:@selector(switchType:)];
    
}

#pragma mark - Override

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// pre-iOS 6 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if (([_userTextField isFirstResponder] || [_passwordTextField isFirstResponder]) &&
        ([touch view] != _userTextField && [touch view] != _passwordTextField)) {
        [_userTextField resignFirstResponder];
        [_passwordTextField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Private methods

- (void)dismissKeyboard {
    [_userTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
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

- (void)switchType {
    if (_type == signIn) {
        self.type = signUp;
    } else {
        self.type = signIn;
    }
}

- (void)sign:(UIButton *)button {
    NSString *email = [_userTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!email || email.length < 1) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"邮箱不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alertView show];
        [UIHelper alertWithMessage:@"邮箱不能为空"];
        return;
    }
    
    NSString *password = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!password || password.length < 1) {
        [UIHelper alertWithMessage:@"密码不能为空"];
        return;
    }
    
    if (![self validateEmail:email]) {
        [UIHelper alertWithMessage:@"邮箱格式错误"];
        return;
    }
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:(_type == signIn ? @selector(signInWithEmail:andPassword:) : @selector(signUpWithEmail:andPassword:))
               withObject:email
               withObject:password];
#pragma clang diagnostic pop
    
//    if (_type == signIn) {
//        NSLog(@"sign in!!!");
//        [self signUpWithEmail:email andPassword:password];
//    } else {
//        NSLog(@"sing up!!!");
//    }
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
    [SVProgressHUD showWithStatus:signUp ? @"注册中" : @"登录中"];
    
    password = [password md5];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    sessionManager.allowAutoLogin = _rememberSwitch.isOn;
    [sessionManager signWithEmail:email andPassword:password atPath:path success:^(NSString *token) {
        //        if (self.rememberSwitch.isOn) {
        //            [SSKeychain setPassword:password forService:kServiceName account:email];
        //        }
        
        if (_success) {
            _success(token);
        }
        
        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
        
        [EncourageView displayScore:(signUp ? EncourageScoreSignUp : EncourageScoreLogin)
                                 at:CGPointMake(CompatibleScreenWidth / 2, 100)];
        
        [self close];
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
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
                                           
                                           [EncourageView displayScore:EncourageScoreLogin
                                                                    at:CGPointMake(CompatibleScreenWidth / 2, 100)];
                                           
                                           [self close:YES];
                                       } failure:^(ResponseError *error) {
                                           NSLog(@"error:%@", error.message);
                                           //                                           [UIHelper alertWithMessage:error.message];
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
