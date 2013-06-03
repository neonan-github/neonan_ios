//
//  SettingViewController.m
//  Neonan
//
//  Created by capricorn on 13-6-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "SettingViewController.h"
#import "AboutViewController.h"
#import "FeedbackViewController.h"

#import "NNDefaultCell.h"

#import <UIAlertView+Blocks.h>
#import <SDImageCache.h>

@interface SettingViewController ()

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    self.view = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    self.tableView = (UITableView *)self.view;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = DarkThemeColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"设置";
    
    UIButton *backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    __weak UITableView *tableView = self.tableView;
    __weak SettingViewController *weakSelf = self;
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.tableViewCellSubclass = [NNDefaultCell class];

            NNDefaultCell *tmpCell = (NNDefaultCell *)cell;
            tmpCell.textLabel.text = @"清除缓存";
            [tmpCell prepareForTableView:tableView indexPath:indexPath];
        } whenSelected:^(NSIndexPath *indexPath) {
            [weakSelf clearCache];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.tableViewCellSubclass = [NNDefaultCell class];
            
            NNDefaultCell *tmpCell = (NNDefaultCell *)cell;
            tmpCell.textLabel.text = @"意见反馈";
            tmpCell.accessoryView = [UIHelper defaultAccessoryView];
            [tmpCell prepareForTableView:tableView indexPath:indexPath];
        } whenSelected:^(NSIndexPath *indexPath) {
            FeedbackViewController *viewController = [[FeedbackViewController alloc] init];
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.tableViewCellSubclass = [NNDefaultCell class];
            
            NNDefaultCell *tmpCell = (NNDefaultCell *)cell;
            tmpCell.textLabel.text = @"关于我们";
            [tmpCell prepareForTableView:tableView indexPath:indexPath];
            tmpCell.accessoryView = [UIHelper defaultAccessoryView];
        } whenSelected:^(NSIndexPath *indexPath) {
            AboutViewController *viewController = [[AboutViewController alloc] init];
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mark - Private methods

- (void)clearCache {
    RIButtonItem *cancelItem = [RIButtonItem item];
    cancelItem.label = @"取消";
    
    RIButtonItem *okItem = [RIButtonItem item];
    okItem.label = @"确定";
    okItem.action = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            [imageCache clearMemory];
            [imageCache clearDisk];
            [imageCache cleanDisk];
            
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
        });
    };
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"清除缓存？"
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:okItem, nil];
    [alertView show];
}

@end
