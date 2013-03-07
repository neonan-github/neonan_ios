//
//  PersonalInfoController.m
//  Neonan
//
//  Created by capricorn on 13-3-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "PersonalInfoController.h"

#import <TTTAttributedLabel.h>

@interface PersonalInfoController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *emblemView0;
@property (weak, nonatomic) IBOutlet UIButton *emblemView1;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *scoreLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *experienceLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *rankLabel;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;

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
    
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_close_normal.png"];
    [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    [self displayVip:NO level:2];
    [self displayScore:1234];
    [self displayExperience:123456];
    [self displayRank:11];
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
}

#pragma mark - Private methods 

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
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

@end
