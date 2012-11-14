//
//  MainController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "MainController.h"
#import "NNNavigationController.h"
#import "BabyDetailController.h"
#import "ArticleDetailController.h"
#import "VideoPlayController.h"
#import "SignController.h"

#import "SMPageControl.h"
#import "HotListCell.h"
#import "BabyCell.h"
#import "CircleHeaderView.h"
#import "SlideShowView.h"
#import "CustomNavigationBar.h"
#import <SVPullToRefresh.h>
#import <TTTAttributedLabel.h>
#import <NYXImagesKit.h>

#import "BabyDetailController.h"
#import "CommentListController.h"

#import "MainSlideShowModel.h"
#import "BabyListModel.h"
#import "CommonListModel.h"

static const NSUInteger kTopChannelIndex = 5;
static const NSUInteger kBabyChannelIndex = 3;
static const NSUInteger kRequestCount = 20;
static const NSString *kRequestCountString = @"20";

typedef enum {
    listTypeLatest = 0,
    listTypeHotest
} listType;

typedef enum {
    requestTypeRefresh = 0,
    requestTypeAppend
} requestType;

typedef enum {
    contentTypeSlide = 0,
    contentTypeArticle,
    contentTypeVideo
} contentType;

@interface MainController () <BabyCellDelegate, SDWebImageManagerDelegate>
@property (nonatomic, unsafe_unretained) UIButton *navLeftButton;
@property (nonatomic, unsafe_unretained) UIButton *navRightButton;
@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) TTTAttributedLabel *slideShowTextLabel;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) UITableView *tableView;
@property (nonatomic, unsafe_unretained) CircleHeaderView *headerView;

@property (nonatomic, strong) NSArray *channelTexts;
@property (nonatomic, strong) NSArray *channelTypes;
@property (nonatomic, assign) NSUInteger channelIndex;

@property (nonatomic, strong) MainSlideShowModel *slideShowModel;
@property (nonatomic, assign) listType type;
@property (nonatomic, strong) id dataModel;// BabyListModel or CommonListModel;

- (UITableViewCell *)createHotListCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)createBabyCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)stringForType:(listType)type;
- (contentType)judgeContentType:(id)item;

- (void)requestForSlideShow:(NSString *)channel;
- (void)requestForList:(NSString *)channel withListType:(listType)type andRequestType:(requestType)requestType;
- (void)requestForVote:(NSString *)babyId withToken:(NSString *)token;

- (void)updateTableView;
- (void)updateSlideShow;
- (void)onChannelChanged;
- (void)onSlideShowItemClicked:(UIView *)view;
- (void)setSlideShowHidden:(BOOL)hidden;
- (void)enterControllerByType:(id)item;
@end

@implementation MainController
@synthesize slideShowView = _slideShowView, pageControl = _pageControl, tableView = _tableView,
headerView = _headerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = DarkThemeColor;
    
    UIButton *navLeftButton = self.navLeftButton = [UIHelper createBarButton:0];
    [navLeftButton setImage:[UIImage imageFromFile:@"icon_user_normal.png"] forState:UIControlStateNormal];
    UIImage *userHighlightedImage = [UIImage imageFromFile:@"icon_user_highlighted.png"];
    [navLeftButton setImage:userHighlightedImage forState:UIControlStateHighlighted];
    [navLeftButton setImage:userHighlightedImage forState:UIControlStateSelected];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = self.navRightButton = [UIHelper createBarButton:5];
    [navRightButton setTitle:[self stringForType:_type] forState:UIControlStateNormal];
    [navRightButton addTarget:self action:@selector(switchListType) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    float layoutY = 0;
    
    CircleHeaderView *headerView = self.headerView = [[CircleHeaderView alloc] initWithFrame:CGRectMake(0, layoutY, CompatibleScreenWidth, 30)];
    headerView.delegate = self;
    headerView.titles = self.channelTexts;
    [headerView.carousel scrollToItemAtIndex:_channelIndex animated:NO];
    [headerView reloadData];
    [self.view addSubview:headerView];
    
    layoutY += 30;
    SlideShowView *slideShowView = self.slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, layoutY, CompatibleScreenWidth, 120)];
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    [self.view addSubview:slideShowView];
    
    TTTAttributedLabel *slideShowTextLabel = self.slideShowTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, layoutY + 120 - 16, CompatibleScreenWidth, 16)];
    slideShowTextLabel.textInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    slideShowTextLabel.clipsToBounds = YES;
    slideShowTextLabel.font = [UIFont systemFontOfSize:8];
    slideShowTextLabel.textColor = [UIColor whiteColor];
//    slideShowTextLabel.text = @"绅士必备 木质调香水最佳推荐";
    slideShowTextLabel.backgroundColor = RGBA(6, 6, 6, 0.7);
    [self.view addSubview:slideShowTextLabel];
    
    SMPageControl *pageControl = self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, layoutY + 120 - 16, CompatibleScreenWidth - 10, 16)];
    pageControl.indicatorDiameter = 5;
    pageControl.indicatorMargin = 4;
    pageControl.currentPageIndicatorTintColor = HEXCOLOR(0x00a9ff);
    pageControl.alignment = SMPageControlAlignmentRight;
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    
    layoutY += 120;
    UITableView *tableView = self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, layoutY, CompatibleScreenWidth, CompatibleContainerHeight - layoutY) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = DarkThemeColor;
//    NSDateFormatter *formatter = tableView.pullToRefreshView.dateFormatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"YYYY MM DD HH:MM:SS"];
    tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [tableView addPullToRefreshWithActionHandler:^{
        // refresh data
        // call [tableView.pullToRefreshView stopAnimating] when done
        [self requestForList:[self.channelTypes objectAtIndex:_channelIndex] withListType:_type andRequestType:requestTypeRefresh];
    }];
    [tableView addInfiniteScrollingWithActionHandler:^{
        // add data to data source, insert new cells into table view
        [self requestForList:[self.channelTypes objectAtIndex:_channelIndex] withListType:_type andRequestType:requestTypeAppend];
    }];
    tableView.showsInfiniteScrolling = NO;
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp
{
    self.navLeftButton = nil;
    self.navRightButton = nil;
    
    self.slideShowView.delegate = nil;
    self.slideShowView.dataSource = nil;
    self.slideShowView = nil;
    
    self.slideShowTextLabel = nil;
    
    self.pageControl = nil;
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView = nil;
    
    self.headerView.delegate = nil;
    self.headerView = nil;
}

- (void)viewDidUnload
{
    [self cleanUp];
    [super viewDidUnload];
}

- (void)dealloc
{
    [self cleanUp];
}

- (void)setType:(listType)type {
    if (_type != type) {
        _type = type;
        [self.navRightButton setTitle:[self stringForType:type] forState:UIControlStateNormal];
        [_tableView.pullToRefreshView triggerRefresh];
    }
}

- (NSArray *)channelTexts {
    if (!_channelTexts) {
        _channelTexts = [NSArray arrayWithObjects:@"首页", @"睿知", @"酷玩", @"宝贝", @"视频", @"精选", @"howto", @"女人", nil];
    }
    
    return  _channelTexts;
}

- (NSArray *)channelTypes {
    if (!_channelTypes) {
        _channelTypes = [NSArray arrayWithObjects:@"home", @"know", @"play", @"baby", @"video", @"top", @"qa", @"women", nil];
    }
    
    return _channelTypes;
}

#pragma mark - UIViewController life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_slideShowView.carousel.currentItemIndex == 0) {
        [self.slideShowView reloadData];
    }
    [self.slideShowView startAutoScroll:2];
    
    if (!_slideShowModel) {
        [self requestForSlideShow:[self.channelTypes objectAtIndex:_channelIndex]];
    }
    
    if (!_dataModel) {
        [_tableView.pullToRefreshView triggerRefresh];
    } else {
        [_tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.slideShowView stopAutoScroll];
}


#pragma mark - SlideShowViewDataSource methods

- (NSUInteger)numberOfItemsInSlideShowView:(SlideShowView *)slideShowView {
    NSUInteger count = _slideShowModel ? MainSlideShowCount : _slideShowModel.list.count;
    [self.pageControl setNumberOfPages:count];
    return count;
}

- (UIView *)slideShowView:(SlideShowView *)slideShowView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, slideShowView.frame.size.width, slideShowView.frame.size.height)];
//        view.clipsToBounds = NO;
//        view.contentMode = UIViewContentModeScaleAspectFill;
        UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSlideShowItemClicked:)];
        [view addGestureRecognizer:tapRecognizer];
    }
    
    NSString *imgUrl = _slideShowModel.list ? [[_slideShowModel.list objectAtIndex:index] imgUrl] : nil;
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:imgUrl]
                                              delegate:self
                                               options:0
                                               success:^(UIImage *image, BOOL cached)
            {
                UIImage *cropedImage = [[image scaleByFactor:view.frame.size.width / image.size.width] cropToSize:view.frame.size usingMode:NYXCropModeTopCenter];
                [((UIImageView *)view) setImage:cropedImage];
            }
                                               failure:nil];
    view.tag = index;
    
    return view;
}

#pragma mark - SlideShowViewDelegate methods

- (void)slideShowViewItemIndexDidChange:(SlideShowView *)slideShowView {
    NSUInteger currentIndex = slideShowView.carousel.currentItemIndex;
    _slideShowTextLabel.text = _slideShowModel.list ? [[_slideShowModel.list objectAtIndex:currentIndex] title] : @"";
    [self.pageControl setCurrentPage:slideShowView.carousel.currentItemIndex];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataModel ? [_dataModel items].count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_channelIndex == kBabyChannelIndex) {
        return [self createBabyCell:tableView forRowAtIndexPath:indexPath];
    }
    
    return [self createHotListCell:tableView forRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _channelIndex == kBabyChannelIndex ? 80 : 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id dataItem = [[_dataModel items] objectAtIndex:indexPath.row];
    [self enterControllerByType:dataItem];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CircleHeaderViewDelegate methods

- (void)currentItemIndexDidChange:(CircleHeaderView *)headView {
    [self performSelector:@selector(onChannelChanged) withObject:nil afterDelay:0.3];
}

#pragma mark - BabyCellDelegate methods

- (void)voteBabyAtIndex:(NSInteger)index {
    if (![_dataModel isKindOfClass:[BabyListModel class]]) {
        return;
    }
    SessionManager *sessionManager = [SessionManager sharedManager];
    NSString *babyId = [[[_dataModel items] objectAtIndex:index] contentId];
    [sessionManager requsetToken:self success:^(NSString *token) {
        [self requestForVote:babyId withToken:token];
    }];
}

- (void)playVideo:(NSString *)videoUrl {
    VideoPlayController *controller = [[VideoPlayController alloc] init];
    NNNavigationController *navController = [[NNNavigationController alloc] initWithRootViewController:controller];
    controller.videoUrl = videoUrl;
    [self.navigationController presentModalViewController:navController animated:YES];
}

#pragma mark - Private methods

- (NSString *)stringForType:(listType)type {
    if (type == listTypeLatest) {
        return @"最新";
    }

    return @"最热";
}

- (contentType)judgeContentType:(id)item {
    if ([item isKindOfClass:[BabyItem class]]) {
        return contentTypeSlide;
    }
    
    NSString *type = [item contentType];
    if ([type isEqualToString:@"article"]) {
        return contentTypeArticle;
    }
    
    if ([type isEqualToString:@"video"]) {
        return contentTypeVideo;
    }
    
    return contentTypeSlide;
}

- (NSString *)requestStringForType:(listType)type {
    if (type == listTypeLatest) {
        return @"new";
    }
    
    return @"hot";
}

- (void)switchListType {
    listType newType = _type == listTypeLatest ? listTypeHotest : listTypeLatest;
    self.type = newType;
}

- (NSInteger)searchBabyById:(NSString *)babyId {
    if (_dataModel && [_dataModel isKindOfClass:[BabyListModel class]]) {
        for (NSUInteger i = 0; i < [_dataModel items].count; i++ ) {
            BabyItem *item = [[_dataModel items] objectAtIndex:i];
            if ([[item contentId] isEqualToString:babyId]) {
                return i;
            }
        }
    }
    
    return -1;
}

#pragma mark - Private Request methods

- (void)requestForSlideShow:(NSString *)channel {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel",
                                [NSNumber numberWithUnsignedInteger:MainSlideShowCount], @"count", nil];
    
    [[NNHttpClient sharedClient] getAtPath:@"image_list" parameters:parameters responseClass:[MainSlideShowModel class] success:^(id<Jsonable> response) {
        self.slideShowModel = (MainSlideShowModel *)response;
        [self updateSlideShow];
        NSLog(@"requestForSlideShow response count:%u", _slideShowModel.list.count);
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
    }];
}

- (void)requestForList:(NSDictionary *)parameters withRequestType:(requestType)requestType {
    BOOL isBabyChannel = [[parameters objectForKey:@"channel"] isEqualToString:@"baby"];
    NSString *path = @"work_list";
    Class responseClass = isBabyChannel ? [BabyListModel class] : [CommonListModel class];
    
    [[NNHttpClient sharedClient] getAtPath:path parameters:parameters responseClass:responseClass success:^(id<Jsonable> response) {
        if (requestType == requestTypeAppend) {
            [self.dataModel appendMoreData:response];
        } else {
            self.dataModel = response;
        }
        
        [self updateTableView];
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
        [_tableView.pullToRefreshView stopAnimating];
        [_tableView.infiniteScrollingView stopAnimating];
    }];
 
}

- (void)requestForList:(NSString *)channel withListType:(listType)type andRequestType:(requestType)requestType {
    NSUInteger offset = (requestType == requestTypeRefresh ? 0 : [_dataModel items].count);
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:channel, @"channel",
                                [self requestStringForType:type], @"sort_type",
                                [NSString stringWithFormat:@"%u", offset], @"offset",
                                kRequestCountString, @"count", nil];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    if ([sessionManager getToken] || [sessionManager canAutoLogin]) {
        [sessionManager requsetToken:self success:^(NSString *token) {
            [parameters setValue:token forKey:@"token"];
            [self requestForList:parameters withRequestType:requestType];
        }];
    } else {
        [self requestForList:parameters withRequestType:requestType];
    }
}

- (void)requestForVote:(NSString *)babyId withToken:(NSString *)token {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:babyId, @"content_id",
                                token, @"token", nil];
    
    [[NNHttpClient sharedClient] postAtPath:@"baby_vote" parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
        NSInteger itemIndex = [self searchBabyById:babyId];
        if (itemIndex < 0) {
            return;
        }
        
        BabyItem *item = [[_dataModel items] objectAtIndex:itemIndex];
        item.voteNum++;
        item.voted = YES;
        
        if ([self isViewLoaded]) {
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:itemIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
    }];
}

#pragma mark - Private UI related

- (UITableViewCell *)createHotListCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *listCellIdentifier = @"HotListCell";
    
    HotListCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellIdentifier];
    if (!cell) {
        cell = [[HotListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listCellIdentifier];
    }
    
    CommonItem *dataItem = [[_dataModel items] objectAtIndex:indexPath.row];
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:dataItem.thumbUrl]];
    cell.titleLabel.text = dataItem.title;
    cell.dateLabel.text = dataItem.date;
    
    return cell;
}

- (UITableViewCell *)createBabyCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString *babyCellIdentifier = @"BabyCell";
    
    BabyCell *cell = [tableView dequeueReusableCellWithIdentifier:babyCellIdentifier];
    if (!cell) {
        cell = [[BabyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:babyCellIdentifier];
        cell.delegate = self;
    }
    
    BabyItem *dataItem = [[_dataModel items] objectAtIndex:indexPath.row];
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:dataItem.photoUrl]];
    cell.titleLabel.text = dataItem.babyName;
    cell.scoreLabel.text = [NSString stringWithFormat:@"%u票", dataItem.voteNum];
    cell.videoShots = dataItem.videoShots;
    cell.videoUrls = dataItem.videoUrls;
    cell.voted = dataItem.voted;
    cell.tag = indexPath.row;
    
    return cell;
}

- (void)updateTableView {
    [_tableView reloadData];
    [_tableView.pullToRefreshView stopAnimating];
    [_tableView.infiniteScrollingView stopAnimating];
    
    _tableView.showsInfiniteScrolling = [_dataModel totalCount] > [_dataModel items].count;
}

- (void)updateSlideShow {
    [_slideShowView reloadData];
    _slideShowTextLabel.text = [[_slideShowModel.list objectAtIndex:_slideShowView.carousel.currentItemIndex] title];
}

- (void)onChannelChanged {
    [[NNHttpClient sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:@"work_list"];
    
    self.channelIndex = _headerView.carousel.currentItemIndex;
    
    self.dataModel = nil;
    [_tableView reloadData];
    
    self.slideShowModel = nil;
    [_slideShowView reloadData];
    
    [self requestForSlideShow:[self.channelTypes objectAtIndex:_channelIndex]];
    [_tableView.pullToRefreshView triggerRefresh];
    
    [self setSlideShowHidden:_channelIndex == kTopChannelIndex];
}

- (void)enterControllerByType:(id)dataItem {
    UIViewController *controller;
    
    switch ([self judgeContentType:dataItem]) {
        case contentTypeArticle:
            controller = [[ArticleDetailController alloc] init];
            [controller performSelector:@selector(setContentId:) withObject:[dataItem contentId]];
            break;
            
        case contentTypeSlide:
            controller = [[BabyDetailController alloc] init];
            [controller performSelector:@selector(setContentType:) withObject:[dataItem contentType]];
            [controller performSelector:@selector(setContentId:) withObject:[dataItem contentId]];
            break;
            
        case contentTypeVideo:
            controller = [[VideoPlayController alloc] init];
            [controller performSelector:@selector(setVideoUrl:) withObject:[dataItem videoUrl]];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onSlideShowItemClicked:(UIGestureRecognizer *)recognizer {
    NSInteger index = recognizer.view.tag;
    
    [self enterControllerByType:[_slideShowModel.list objectAtIndex:index]];
}

- (void)setSlideShowHidden:(BOOL)hidden {
    if (_slideShowView.hidden != hidden) {
        [UIView beginAnimations:nil context:nil];
        _slideShowView.hidden = hidden;
        CGRect frame = _tableView.frame;
        CGFloat delta = _slideShowView.frame.size.height * (hidden ? 1 : -1);
        frame.origin.y -= delta;
        frame.size.height += delta;
        _tableView.frame = frame;
        [UIView commitAnimations];
    }
}

@end
