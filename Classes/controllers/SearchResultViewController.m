//
//  SearchResultViewController.m
//  Neonan
//
//  Created by capricorn on 13-6-6.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "SearchResultViewController.h"

#import "ChannelListViewCell.h"

#import "CommonListModel.h"

#import <UIImageView+WebCache.h>
#import <SVPullToRefresh.h>
#import <TTTAttributedLabel.h>

static NSString *const kSearchChannel = @"search";

@interface SearchResultViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) UITextField *searchField;
@property (nonatomic, weak) TTTAttributedLabel *resultLabel;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) CommonListModel *dataModel;

@end

@implementation SearchResultViewController

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
    
    [self configSearchField];
    
    UIButton *backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    TTTAttributedLabel *resultLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 30)];
    self.resultLabel = resultLabel;
    resultLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    resultLabel.textInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    resultLabel.backgroundColor = HEXCOLOR(0x232323);
    resultLabel.textColor = [UIColor whiteColor];
    resultLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:resultLabel];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, CompatibleScreenWidth, self.view.height - 30)
                                                          style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
    [tableView addPullToRefreshWithActionHandler:^{
        [self requestForList:kSearchChannel requestType:RequestTypeRefresh];
    }];
    tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        [self requestForList:kSearchChannel requestType:RequestTypeAppend];
    }];
    tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    tableView.showsInfiniteScrolling = NO;
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
    
    self.resultLabel = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
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
                                                        andChannel:kSearchChannel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

#pragma mark - Private Request methods

- (void)requestForList:(NSString *)channel requestType:(RequestType)requestType {
    NSUInteger offset = (requestType == RequestTypeRefresh ? 0 : [self.dataModel items].count);
    NSDictionary *parameters = @{@"channel": channel, @"sort_type": @"new", @"count": @(20),
                                 @"offset": @(offset), @"q": self.keyword};
    
    void (^done)() = ^{
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (self.dataModel.totalCount && self.dataModel.items.count) {
                self.resultLabel.text = [NSString stringWithFormat:@"找到关于“%@”相关结果%d个", self.keyword, self.dataModel.totalCount];
            } else {
                self.resultLabel.text = [NSString stringWithFormat:@"抱歉，没有找到关于“%@”的相关结果", self.keyword];
            }
            
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

- (void)configSearchField {
    UIImageView *fieldBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 186, 28)];
    fieldBgView.userInteractionEnabled = YES;
    fieldBgView.image = [[UIImage imageNamed:@"bg_search_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    
    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(13, 0, 143, 28)];
    self.searchField = searchField;
    searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchField.font = [UIFont systemFontOfSize:14];
    searchField.returnKeyType = UIReturnKeySearch;
    searchField.delegate = self;
    searchField.text = self.keyword;
    [fieldBgView addSubview:searchField];
    
    self.navigationItem.titleView = fieldBgView;
}

@end
