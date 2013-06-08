//
//  RightMenuViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-29.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "RightMenuViewController.h"
#import "SignViewController.h"
#import "PersonalInfoViewController.h"
#import "FavoritesViewController.h"
#import "SettingViewController.h"

#import "SideMenuCell.h"

#import "UserInfoModel.h"

#import <UIImageView+WebCache.h>
#import <UIAlertView+Blocks.h>

static NSString *const kSidePanelStateKey = @"state";

@interface RightMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *emblemView0;
@property (weak, nonatomic) IBOutlet UIButton *emblemView1;
@property (weak, nonatomic) IBOutlet UIButton *powerButton;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) NSArray *menuTexts;

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
    
    self.view.backgroundColor = HEXCOLOR(0x121212);
    
    UIImageView *firstSeparatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, CompatibleScreenWidth, 2)];
    firstSeparatorView.image = [UIImage imageFromFile:@"img_menu_separator.png"];
    [self.tableView addSubview:firstSeparatorView];
    
    [self.powerButton setBackgroundImage:[[UIImage imageNamed:@"bg_btn_power_normal"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]
                      forState:UIControlStateNormal];
    [self.powerButton setBackgroundImage:[[UIImage imageNamed:@"bg_btn_power_highlighted"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]
                      forState:UIControlStateHighlighted];
    
    [self updateStatus:[[SessionManager sharedManager] canAutoLogin]];
    
    [self.sidePanelController addObserver:self forKeyPath:kSidePanelStateKey options:NSKeyValueObservingOptionInitial context:NULL];
}

- (void)cleanUp {
    [super cleanUp];
    
    [self.sidePanelController removeObserver:self forKeyPath:kSidePanelStateKey];
    
    self.avatarView = nil;
    self.nameLabel = nil;
    self.emblemView0 = nil;
    self.emblemView1 = nil;
    self.powerButton = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
    
    _menuTexts = nil;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    void (^itemClicked)() = ^{
        NSArray *classes = @[[PersonalInfoViewController class], [FavoritesViewController class], [SettingViewController class]];
        self.sidePanelController.centerPanel = self.sidePanelController.centerPanel;
        
        NNNavigationController *topNavController = (NNNavigationController *)((NeonanAppDelegate *)ApplicationDelegate).containerController.currentViewController;
        UIViewController *viewController = [[classes[indexPath.row] alloc] init];
        [topNavController pushViewController:viewController animated:NO];
    };
    
    if (indexPath.row < 2 && ![[SessionManager sharedManager] canAutoLogin]) {
        [[SessionManager sharedManager] requsetToken:self success:^(NSString *token) {
            [self updateStatus:YES];
            
            itemClicked();
        }];
    } else {
        itemClicked();
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

#pragma mark - Private Request methods

- (IBAction)onPowerClicked:(id)sender {
    if ([[SessionManager sharedManager] canAutoLogin]) {
        RIButtonItem *cancelItem = [RIButtonItem item];
        cancelItem.label = @"取消";
        
        RIButtonItem *okItem = [RIButtonItem item];
        okItem.label = @"确定";
        okItem.action = ^{
            [[SessionManager sharedManager] logout];
            [self updateStatus:NO];
        };
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"确定注销？"
                                                   cancelButtonItem:cancelItem
                                                   otherButtonItems:okItem, nil];
        [alertView show];
    } else {
        [[SessionManager sharedManager] requsetToken:self success:^(NSString *token) {
            [self updateStatus:YES];
        }];
    }
}


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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kSidePanelStateKey]) {
        JASidePanelState state = [[object valueForKeyPath:kSidePanelStateKey] integerValue];
        if (state == JASidePanelRightVisible) {
            [self updateStatus:[[SessionManager sharedManager] canAutoLogin]];
        }
    }
}

@end
