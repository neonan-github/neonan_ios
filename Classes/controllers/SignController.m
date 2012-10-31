//
//  SignController.m
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SignController.h"
#import "NNNavigationController.h"
#import <DCRoundSwitch.h>

@interface SignController ()
@property (unsafe_unretained, nonatomic) TTTAttributedLabel *switchTypeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *userTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *passwordTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *actionButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *rememberPWLabel;
@property (unsafe_unretained, nonatomic) IBOutlet DCRoundSwitch *rememberSwitch;
@end

@implementation SignController

- (id)initWithType:(signType)type
{
    self = [super init];
    if (self) {
        // Custom initialization
        _type = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
//                                                                             style:UIBarButtonItemStyleDone
//                                                                            target:self
//                                                                            action:@selector(close)];
    
    UIButton *cancelButton = [UIHelper createBarButton:10];
    cancelButton.frame = CGRectMake(14, 8, 42, 24);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    self.view.backgroundColor = DarkThemeColor;
    
    [_actionButton addTarget:self action:@selector(sign:) forControlEvents:UIControlEventTouchUpInside];
    
    TTTAttributedLabel *switchTypeLabel = self.switchTypeLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(275, 8, 42, 24)];
    switchTypeLabel.delegate = self;
    switchTypeLabel.font = [UIFont systemFontOfSize:12];
    switchTypeLabel.backgroundColor = [UIColor clearColor];
    switchTypeLabel.textColor = [UIColor whiteColor];
    switchTypeLabel.lineBreakMode = UILineBreakModeWordWrap;
    switchTypeLabel.numberOfLines = 0;
    switchTypeLabel.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setValue:(id)[HEXCOLOR(0x16a1e8) CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    [mutableActiveLinkAttributes setValue:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    switchTypeLabel.activeLinkAttributes = mutableActiveLinkAttributes;
    
    [self.view addSubview:switchTypeLabel];
    
    self.type = _type;
    
    _rememberSwitch.on = YES;
    _rememberSwitch.onText = @"";
    _rememberSwitch.offText = @"";
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard)];
//    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.switchTypeLabel = nil;
    [self setUserTextField:nil];
    [self setPasswordTextField:nil];
    [self setActionButton:nil];
    [self setRememberPWLabel:nil];
    [self setRememberSwitch:nil];
    [super viewDidUnload];
}

#pragma mark - UIViewController life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setType:(signType)type {
    _type = type;
    
    self.switchTypeLabel.text = (_type == signUp ? @"登录" : @"注册");
    NSRange r = NSMakeRange(0, 2);
    [self.switchTypeLabel addLinkToURL:[NSURL URLWithString:@"action://switch-type"] withRange:r];
    
    [_actionButton setTitle:(_type == signIn ? @"登录" : @"注册") forState:UIControlStateNormal];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(_type == signIn ? @"注册" : @"登录")
//                                                                              style:UIBarButtonItemStylePlain
//                                                                             target:self
//                                                                             action:@selector(switchType:)];
    
}

#pragma mark -TTTAttributedLabelDelegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [self switchType];
}

#pragma mark - Override

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

- (void)switchType {
    if (_type == signIn) {
        self.type = signUp;
    } else {
        self.type = signIn;
    }
}

- (void)sign:(UIButton *)button {
    if (_type == signIn) {
        NSLog(@"sign in!!!");
    } else {
        NSLog(@"sing up!!!");
    }
}

@end
