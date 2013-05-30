//
//  PersonalInfoController.m
//  Neonan
//
//  Created by capricorn on 13-3-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "PersonalInfoController.h"
#import "InfoEditViewController.h"
#import "PurchaseVIPController.h"

#import "UserInfoModel.h"

#import <TTTAttributedLabel.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

@interface PersonalInfoController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *emblemView0;
@property (weak, nonatomic) IBOutlet UIButton *emblemView1;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *scoreLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *experienceLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationHintLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (nonatomic, strong) UserInfoModel *userInfoModel;
@property (nonatomic, strong) UIImage *avatarImage;

@end

@implementation PersonalInfoController

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
    self.title = @"个人中心";
    
    UIButton *navLeftButton = [UIHelper createBackButton:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = [UIHelper createRightBarButton:@"icon_nav_edit.png"];
    [navRightButton addTarget:self action:@selector(editInfo:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    self.view.backgroundColor = DarkThemeColor;
    
    _buyButton.hidden = !_userInfoModel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self requestUserInfo];
    });
}

- (void)cleanUp {
    self.avatarView = nil;
    self.nameLabel = nil;
    self.emblemView0 = nil;
    self.emblemView1 = nil;
    self.scoreLabel = nil;
    self.experienceLabel = nil;
    self.rankLabel = nil;
    self.buyButton = nil;
    self.expirationHintLabel = nil;
}

#pragma mark - Private Request related

- (void)requestUserInfo {
    [SVProgressHUD showWithStatus:@"正在获取信息"];
    [[SessionManager sharedManager] requsetToken:self success:^(NSString *token) {
        [[NNHttpClient sharedClient] getAtPath:kPathGetUserInfo
                                     parameters:@{@"token" : token}
                                  responseClass:[UserInfoModel class]
                                        success:^(id<Jsonable> response) {
                                            [SVProgressHUD dismiss];
                                            self.userInfoModel = response;
                                            [self updateData];
                                        }
                                        failure:^(ResponseError *error) {
                                            DLog(@"error:%@", error.message);
                                            [SVProgressHUD dismiss];
                                            [UIHelper alertWithMessage:error.message];
                                        }];
    }];
}

#pragma mark - Private methods 

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateData {
    if (_avatarImage) {
        _avatarView.image = _avatarImage;
    } else {
        [_avatarView setImageWithURL:[NSURL URLWithString:_userInfoModel.avatar]
                    placeholderImage:[UIImage imageNamed:@"img_default_avatar.jpg"]];
    }
    
    _nameLabel.text = _userInfoModel.username;
    
    [self displayVip:_userInfoModel.isVip level:_userInfoModel.level];
    [self displayScore:_userInfoModel.point];
    [self displayExperience:_userInfoModel.exp];
    [self displayRank:_userInfoModel.rank];
    
    _expirationHintLabel.text = _userInfoModel.isVip ?  [NSString stringWithFormat:@"到期时间：%@", _userInfoModel.expirationText] : @"";
    [_buyButton setBackgroundImage:[UIImage imageFromFile:_userInfoModel.isVip ? @"bg_btn_renew_vip.png" : @"bg_btn_buy_vip.png"]
                          forState:UIControlStateNormal];
    _buyButton.hidden = NO;
}

- (void)displayVip:(BOOL)vip level:(NSInteger)level {
    if (vip) {
        [_emblemView0 setBackgroundImage:[UIImage imageFromFile:@"icon_vip.png"] forState:UIControlStateNormal];
    }
    
    _emblemView1.hidden = !vip;
    
    UIButton *levelView = vip ? _emblemView1 : _emblemView0;
    [levelView setBackgroundImage:[UIImage imageFromFile:@"icon_level.png"] forState:UIControlStateNormal];
    [levelView setTitle:@(level).stringValue forState:UIControlStateNormal];
}

- (void)displayScore:(NSInteger)score {
    NSString *text = [NSString stringWithFormat:@"积分：%d", score];
    [self displayLabel:_scoreLabel text:text numberRange:NSMakeRange(3, text.length - 3)];
}

- (void)displayExperience:(NSInteger)experience {
    NSString *text = [NSString stringWithFormat:@"经验值：%d", experience];
    [self displayLabel:_experienceLabel text:text numberRange:NSMakeRange(4, text.length - 4)];
}

- (void)displayRank:(NSInteger)rank {
    NSString *text = [NSString stringWithFormat:@"排名：%d", rank];
    [self displayLabel:_rankLabel text:text numberRange:NSMakeRange(3, text.length - 3)];
}

- (void)displayLabel:(TTTAttributedLabel *)label text:(NSString *)text numberRange:(NSRange)range{
    [label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)HEXCOLOR(0x0096ff).CGColor range:range];
        
        return mutableAttributedString;
    }];
}

- (IBAction)editInfo:(id)sender {
    if (!_userInfoModel) {
        return;
    }
    
    InfoEditViewController *controller = [[InfoEditViewController alloc] init];
    controller.avatarImage = _avatarView.image;
    controller.nickName = _userInfoModel.username;
    controller.infoChangedBlock = ^(UIImage *avatarImage, NSString *name) {
        _avatarView.image = avatarImage;
        _nameLabel.text = name;
    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.8f];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view.window cache:NO];
//    [self presentModalViewController:[[NNNavigationController alloc] initWithRootViewController:controller] animated:NO];
//    [UIView commitAnimations];
}

- (IBAction)buyVIP:(id)sender {
    PurchaseVIPController *controller = [[PurchaseVIPController alloc] init];
    [self presentModalViewController:[[NNNavigationController alloc] initWithRootViewController:controller] animated:YES];
}

@end
