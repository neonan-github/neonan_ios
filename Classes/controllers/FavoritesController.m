//
//  FavoritesController.m
//  Neonan
//
//  Created by capricorn on 13-3-4.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "FavoritesController.h"
#import "GalleryDetailController.h"
#import "ArticleDetailController.h"
#import "VideoPlayController.h"

#import "CommonListModel.h"

#import "HotListCell.h"

#import <SVPullToRefresh.h>

static NSString *const kChannel = @"fav";

@interface FavoritesController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UILabel *countLabel;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UILabel *noFavoritesHintLabel;

@property (nonatomic, strong) CommonListModel *dataModel;

@end

@implementation FavoritesController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    self.view = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.tableView = (UITableView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"我的收藏";
    
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_nav_close.png"];
    [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.textAlignment = NSTextAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:countLabel];
    self.countLabel = countLabel;
    
    UITableView *tableView = _tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = DarkThemeColor;
    
    [tableView addPullToRefreshWithActionHandler:^{
        [self requestForList:RequestTypeRefresh];
    }];
    tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        [self requestForList:RequestTypeAppend];
    }];
    tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    tableView.showsInfiniteScrolling = NO;
}

- (void)cleanUp {
    self.countLabel = nil;
    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_dataModel) {
        [_tableView.pullToRefreshView performSelector:@selector(triggerRefresh) withObject:nil afterDelay:0.5];
    } else {
        [_tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *listCellIdentifier = @"HotListCell";
    
    HotListCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellIdentifier];
    if (!cell) {
        cell = [[HotListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listCellIdentifier];
    }
    
    CommonItem *dataItem = [[_dataModel items] objectAtIndex:indexPath.row];
    
    Record *record = [[Record alloc] init];
    record.contentId = dataItem.contentId;
    record.contentType = dataItem.contentType;
    
    cell.viewed = [[HistoryRecorder sharedRecorder] isRecorded:record];
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:dataItem.thumbUrl] placeholderImage:[UIImage imageNamed:@"img_common_list_place_holder.png"]];
    cell.titleLabel.text = dataItem.title;
    cell.descriptionLabel.text = dataItem.readableContentType;
    cell.dateLabel.text = dataItem.date;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id dataItem = [[_dataModel items] objectAtIndex:indexPath.row];
    [self enterControllerByType:dataItem atOffset:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Request related

- (void)requestForList:(RequestType)requestType {
    [[SessionManager sharedManager] requsetToken:self success:^(NSString *token) {
        NSUInteger offset = (requestType == RequestTypeRefresh ? 0 : [_dataModel items].count);
        NSDictionary *params = @{@"token": token, @"channel": @"fav", @"sort_type": @(SortTypeLatest), @"offset": @(offset), @"count": @(20)};
        
        [[NNHttpClient sharedClient] getAtPath:kPathWorkList parameters:params responseClass:[CommonListModel class] success:^(id<Jsonable> response) {
            if (requestType == RequestTypeAppend) {
                [self.dataModel appendMoreData:response];
            } else {
                self.dataModel = response;
            }
            
            [self updateData:requestType];
        } failure:^(ResponseError *error) {
            DLog(@"error:%@", error.message);
            if (self.isVisible) {
                [UIHelper alertWithMessage:error.message];
            }
            [_tableView.pullToRefreshView stopAnimating];
            [_tableView.infiniteScrollingView stopAnimating];
        }];
    }];
}

#pragma mark - Private methods

- (UILabel *)noFavoritesHintLabel {
    if (!_noFavoritesHintLabel) {
        UILabel *noFavoritesHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, CompatibleScreenWidth, 20)];
        self.noFavoritesHintLabel = noFavoritesHintLabel;
        noFavoritesHintLabel.backgroundColor = [UIColor clearColor];
        noFavoritesHintLabel.textAlignment = NSTextAlignmentCenter;
        noFavoritesHintLabel.textColor = [UIColor whiteColor];//RGB(10, 10, 10);
        noFavoritesHintLabel.text = @"还没有收藏";
        [self.view addSubview:noFavoritesHintLabel];
    }
    
    return _noFavoritesHintLabel;
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateData:(RequestType)requestType {
    _countLabel.text = [NSString stringWithFormat:@"共%d篇", _dataModel.totalCount];
    self.noFavoritesHintLabel.hidden = _dataModel.totalCount > 0;
    
    [self updateTableView:requestType];
}

- (void)updateTableView:(RequestType)requestType {
    [_tableView reloadData];
    if (requestType == RequestTypeRefresh) {
        [_tableView.pullToRefreshView stopAnimating];
    } else {
        [_tableView.infiniteScrollingView stopAnimating];
    }
    
    _tableView.showsInfiniteScrolling = [_dataModel totalCount] > [_dataModel items].count;
}

- (void)enterControllerByType:(id)dataItem atOffset:(NSUInteger)offset{
    id controller;
    
    switch ([self judgeContentType:dataItem]) {
        case ContentTypeArticle:
            controller = [[ArticleDetailController alloc] init];
            [controller setContentId:[dataItem contentId]];
            [controller setContentTitle:[dataItem title]];
            [controller setChannel:kChannel];
            break;
            
        case ContentTypeSlide:
            controller = [[GalleryDetailController alloc] init];
            [controller setContentType:[dataItem contentType]];
            [controller setContentId:[dataItem contentId]];
            [controller setChannel:kChannel];
            [controller setContentTitle:[dataItem title]];
            break;
        
        default:
            controller = nil;
            break;
    }
    
    [controller setTitle:@"我的收藏"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (ContentType)judgeContentType:(id)item {
    NSString *type = [item contentType];
    if ([type isEqualToString:@"article"]) {
        return ContentTypeArticle;
    }
    
    if ([type isEqualToString:@"video"]) {
        return ContentTypeVideo;
    }
    
    return ContentTypeSlide;
}

@end
