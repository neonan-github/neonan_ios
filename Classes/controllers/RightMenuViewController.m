//
//  RightMenuViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-29.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "RightMenuViewController.h"

#import "SideMenuCell.h"

#import "UserInfoModel.h"

#import <UIImageView+WebCache.h>

@interface RightMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *emblemView0;
@property (weak, nonatomic) IBOutlet UIButton *emblemView1;
@property (weak, nonatomic) IBOutlet UIButton *powerButton;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) NSArray *menuTexts;

@property (nonatomic, strong) UserInfoModel *userInfoModel;

@end

@implementation RightMenuViewController
@synthesize menuTexts =_menuTexts;

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
    
    self.view.backgroundColor = DarkThemeColor;
    
    UIImageView *firstSeparatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, CompatibleScreenWidth, 2)];
    firstSeparatorView.image = [UIImage imageFromFile:@"img_menu_separator.png"];
    [self.tableView addSubview:firstSeparatorView];
    
    [self.powerButton setBackgroundImage:[[UIImage imageFromFile:@"bg_btn_power_normal.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]
                      forState:UIControlStateNormal];
    [self.powerButton setBackgroundImage:[[UIImage imageFromFile:@"bg_btn_power_highlighted.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]
                      forState:UIControlStateHighlighted];
    
    [self updateStatus:[[SessionManager sharedManager] canAutoLogin]];
}

- (void)cleanUp {
    [super cleanUp];
    
    self.avatarView = nil;
    self.nameLabel = nil;
    self.emblemView0 = nil;
    self.emblemView1 = nil;
    self.powerButton = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DLog(@"viewDidAppear");
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTexts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    SideMenuCell *cell = (SideMenuCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SideMenuCell alloc] initWithReuseIdentifier:cellIdentifier];
        cell.cellStyle = SideMenuCellStyleRight;
    }
    
    cell.textLabel.text = self.menuTexts[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.sidePanelController.centerPanel = self.sidePanelController.centerPanel;
//    [self performSelector:@selector(changeController:) withObject:@(indexPath.row) afterDelay:0.2];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

#pragma mark - Private Request methods



#pragma mark - Private methods

- (NSArray *)menuTexts {
    if (!_menuTexts) {
        _menuTexts = @[@"个人中心", @"我的收藏", @"设置"];
    }
    
    return _menuTexts;
}

- (void)displayVip:(BOOL)vip level:(NSInteger)level {
    if (vip) {
        [self.emblemView0 setBackgroundImage:[UIImage imageFromFile:@"icon_vip.png"] forState:UIControlStateNormal];
    }
    
    self.emblemView1.hidden = !vip;
    
    UIButton *levelView = vip ? self.emblemView1 : self.emblemView0;
    [levelView setBackgroundImage:[UIImage imageFromFile:@"icon_level.png"] forState:UIControlStateNormal];
    [levelView setTitle:@(level).stringValue forState:UIControlStateNormal];
}

- (void)updateStatus:(BOOL)loggined {
    self.nameLabel.hidden = self.emblemView0.hidden =
    self.emblemView1.hidden = !loggined;
    
    CGRect frame = self.powerButton.frame;
    frame.size.width = loggined ? 30 : 80;
    frame.origin.x = 315 - frame.size.width;
    self.powerButton.frame = frame;
    
    [self.powerButton setTitle:loggined ? @"" : @"登录" forState:UIControlStateNormal];
    [self.powerButton setImage:loggined ? [UIImage imageFromFile:@"icon_power.png"] : nil forState:UIControlStateNormal];
    
    self.avatarView.image = [UIImage imageFromFile:@"img_default_avatar.jpg"];
    
    if (loggined) {
        [self updateData];
    }
}

- (void)updateData {
    [[SessionManager sharedManager] requsetUserInfo:self
                                        forceUpdate:NO
                                            success:^(UserInfoModel *info) {
                                                [self.avatarView setImageWithURL:[NSURL URLWithString:info.avatar]];
                                                self.nameLabel.text = info.username;
                                                
                                                [self displayVip:info.vip level:info.level];
                                            }
                                            failure:^(ResponseError *error) {
                                                
                                            }];
    
}

@end
