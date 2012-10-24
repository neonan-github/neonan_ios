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
    _userTextField.leftMargin = [NSNumber numberWithFloat:30];
    _passwordTextField.leftMargin = [NSNumber numberWithFloat:30];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserTextField:nil];
    [self setPasswordTextField:nil];
    [self setLeftButton:nil];
    [self setRightButton:nil];
    [super viewDidUnload];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    UITouch *touch = [[event allTouches] anyObject];
//    if (([_userTextField isFirstResponder] || [_passwordTextField isFirstResponder]) &&
//        ([touch view] != _userTextField && [touch view] != _passwordTextField)) {
//        [_userTextField resignFirstResponder];
//        [_passwordTextField resignFirstResponder];
//    }
//    [super touchesBegan:touches withEvent:event];
//}

-(void)dismissKeyboard {
    [_userTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}
@end
