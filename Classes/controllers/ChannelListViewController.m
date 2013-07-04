//
//  ChannelListViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-29.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "ChannelListViewController.h"

#import "ChannelListViewCell.h"

#import "CommonListModel.h"

#import <UIImageView+WebCache.h>
#import <SVPullToRefresh.h>

@interface ChannelListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) CommonListModel *dataModel;

@end

@implementation ChannelListViewController

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
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = DarkThemeColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    self.navigationItem.titleView = [UIHelper createLogoView];
    
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_menu_normal.png"];
    [navLeftButton addTarget:self action:@selector(showLeftPanel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = [UIHelper createLeftBarButton:@"icon_nav_account.png"];
    [navRightButton addTarget:self action:@selector(showRightPanel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self requestForList:self.channel requestType:RequestTypeRefresh];
    }];
    self.tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self requestForList:self.channel requestType:RequestTypeAppend];
    }];
    self.tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.tableView.showsInfiniteScrolling = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.dataModel) {
        [self.tableView triggerPullToRefresh];
    } else {
        [self.tableView reloadData];
    }
}

- (void)cleanUp {
    [super cleanUp];
    
    self.dataModel = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
}

- (void)setSubChannel:(NSString *)subChannel {
    if (![_subChannel isEqualToString:subChannel]) {
        _subChannel = [subChannel copy];
        self.tableView.contentOffset = CGPointMake(0, 0);
        [self.tableView triggerPullToRefresh];
    }
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    ChannelListViewCell *cell = (ChannelListViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ChannelListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CommonItem *dataItem = self.dataModel.items[indexPath.row];
    
    Record *record = [[Record alloc] init];
    record.contentId = dataItem.contentId;
    record.contentType = dataItem.contentType;
    
    cell.viewed = [[HistoryRecorder sharedRecorder] isRecorded:record];
    
    cell.tagImageView.image = [dataItem.contentType isEqualToString:@"video"] ? [UIImage imageNamed:@"icon_video_tag"] : nil;
    
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:dataItem.thumbUrl]
                   placeholderImage:[UIImage imageNamed:@"img_placeholder_common.png"]];
    
    cell.titleLabel.text = dataItem.title;
    cell.dateLabel.text = dataItem.date;
    [cell setContentType:dataItem.contentType];

    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CommonItem *dataItem = self.dataModel.items[indexPath.row];
    [(NeonanAppDelegate *)ApplicationDelegate navigationController:self.navigationController
                                          pushViewControllerByType:dataItem
                                                        andChannel:self.channel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

#pragma mark - Private Request methods

- (void)requestForList:(NSString *)channel requestType:(RequestType)requestType {
    NSUInteger offset = (requestType == RequestTypeRefresh ? 0 : [self.dataModel items].count);
    NSMutableDictionary *parameters = [@{@"channel": channel, @"sort_type": @"new", @"count": @(20),
                                 @"offset": @(offset)} mutableCopy];
    if (self.subChannel) {
        [parameters setObject:self.subChannel forKey:@"sub_channel"];
    }
    
    void (^done)() = ^{
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self updateTableView:requestType];
        });
    };
    
    [[NNHttpClient sharedClient] getAtPath:kPathWorkList
                                parameters:parameters
                             responseClass:[CommonListModel class]
                                   success:^(id<Jsonable> response) {
                                       if (requestType == RequestTypeAppend) {
                                           [self.dataModel appendMoreData:response];
                                       } else {
                                           self.dataModel = response;
                                       }
                                       
                                       done();
                                   } failure:^(ResponseError *error) {
                                       if (self.isVisible) {
                                           [UIHelper alertWithMessage:error.message];
                                       }
                                       
                                       done();
                                   }];
}

#pragma mark - Private methods

- (void)updateTableView:(RequestType)requestType {
    [self.tableView reloadData];
    
    if (requestType == RequestTypeRefresh) {
        [self.tableView.pullToRefreshView stopAnimating];
    } else {
        [self.tableView.infiniteScrollingView stopAnimating];
    }
    
    self.tableView.showsInfiniteScrolling = [self.dataModel totalCount] > [self.dataModel items].count;
}

@end
