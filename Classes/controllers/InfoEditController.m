//
//  InfoEditController.m
//  Neonan
//
//  Created by capricorn on 13-3-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "InfoEditController.h"

#import <UIImageView+WebCache.h>

@interface InfoEditController ()

@property (weak, nonatomic) IBOutlet UIView *avatarBlockView;
@property (weak, nonatomic) IBOutlet UIView *nameBlockView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation InfoEditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"编辑资料";
    
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_close_normal.png"];
    [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = [UIHelper createRightBarButton:@"icon_done_normal.png"];
    [navRightButton addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    _avatarBlockView.layer.cornerRadius = 8;
    _nameBlockView.layer.cornerRadius = 8;
    
    _avatarView.image = [UIImage imageNamed:@"img_default_avatar.jpg"];
}

- (void)cleanUp {
    self.avatarBlockView = nil;
    self.nameBlockView = nil;
    self.avatarView = nil;
    self.nameField = nil;
}

#pragma mark - Private methods

- (void)close {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.window cache:NO];
    [self dismissModalViewControllerAnimated:NO];
    [UIView commitAnimations];
}

@end
