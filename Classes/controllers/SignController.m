//
//  SignController.m
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "SignController.h"

@interface SignController ()

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(close:)];
    
    _userTextField.leftMargin = [NSNumber numberWithFloat:30];
    _passwordTextField.leftMargin = [NSNumber numberWithFloat:30];
    [_actionButton addTarget:self action:@selector(sign:) forControlEvents:UIControlEventTouchUpInside];
    
    self.type = _type;
    
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
    [self setUserTextField:nil];
    [self setPasswordTextField:nil];
    [self setActionButton:nil];
    [super viewDidUnload];
}

- (void)setType:(signType)type {
    _type = type;
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
//    [button setTitle:@"Delete" forState:UIControlStateNormal];
//    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
//    [button.layer setCornerRadius:4.0f];
//    [button.layer setMasksToBounds:YES];
//    [button.layer setBorderWidth:1.0f];
//    [button.layer setBorderColor: [[UIColor grayColor] CGColor]];
//    button.frame=CGRectMake(0.0, 100.0, 60.0, 30.0);
//    [button addTarget:self action:@selector(batchDelete) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* deleteItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.rightBarButtonItem = deleteItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(_type == signIn ? @"注册" : @"登录")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(switchType:)];
    [_actionButton setTitle:(_type == signIn ? @"登录" : @"注册") forState:UIControlStateNormal];
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

- (void)close:(UIBarButtonItem *)button {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)switchType:(UIBarButtonItem *)button {
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
