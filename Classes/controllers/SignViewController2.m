//
//  SignViewController2.m
//  Neonan
//
//  Created by Wu Yunpeng on 13-6-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNTextField.h"

#import "SignViewController2.h"

@interface SignViewController2 ()

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

@end

@implementation SignViewController2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.flipView.contentSize = CGSizeMake(CompatibleScreenWidth * 2, self.flipView.height);
    
    self.nameBgView0.image = [[UIImage imageFromFile:@"bg_left_sign_field_normal.png"] stretchableImageWithLeftCapWidth:35 topCapHeight:27];
    self.passwordBgView0.image = [[UIImage imageFromFile:@"bg_left_sign_field_highlighted.png"] stretchableImageWithLeftCapWidth:35 topCapHeight:27];
    self.nameBgView1.image = [[UIImage imageFromFile:@"bg_right_sign_field_normal.png"] stretchableImageWithLeftCapWidth:35 topCapHeight:27];
    self.passwordBgView1.image = [[UIImage imageFromFile:@"bg_right_sign_field_highlighted.png"] stretchableImageWithLeftCapWidth:35 topCapHeight:27];
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
}

- (IBAction)onSignUpButtonClicked:(id)sender {
    [self.flipView scrollRectToVisible:CGRectMake(0, 0, CompatibleScreenWidth, self.flipView.height)
                              animated:YES];
    
    [UIView beginAnimations:nil context:NULL];
    self.signUpButton.frame = CGRectMake(56, 295, 100, 38);
    self.signInButton.frame = CGRectMake(255, 296, 96, 36);
    [UIView commitAnimations];
}

- (IBAction)onSignInButtonClicked:(id)sender {
    [self.flipView scrollRectToVisible:CGRectMake(CompatibleScreenWidth, 0, CompatibleScreenWidth, self.flipView.height)
                              animated:YES];
    [UIView beginAnimations:nil context:NULL];
    self.signUpButton.frame = CGRectMake(-29, 296, 96, 36);
    self.signInButton.frame = CGRectMake(158, 295, 100, 38);
    [UIView commitAnimations];
}

@end
