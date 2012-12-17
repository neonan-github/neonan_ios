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
#import "AboutController.h"
#import "FeedbackController.h"

#import "SMPageControl.h"
#import "HotListCell.h"
#import "BabyCell.h"
#import "CircleHeaderView.h"
#import "SlideShowView.h"
#import "CustomNavigationBar.h"
#import "NNDropDownMenu.h"

#import <SDImageCache.h>
#import <SVPullToRefresh.h>
#import <TTTAttributedLabel.h>
#import <NYXImagesKit.h>
#import <UIAlertView+Blocks.h>

#import "BabyDetailController.h"
#import "CommentListController.h"

#import "MainSlideShowModel.h"
#import "BabyListModel.h"
#import "CommonListModel.h"

static const NSUInteger kTopChannelIndex = 4;
static const NSUInteger kBabyChannelIndex = NSUIntegerMax;
static const NSUInteger kRequestCount = 20;
static const NSString *kRequestCountString = @"20";

typedef enum {
    requestTypeRefresh = 0,
    requestTypeAppend
} requestType;

typedef enum {
    contentTypeSlide = 0,
    contentTypeArticle,
    contentTypeVideo
} contentType;

@interface MainController () <BabyCellDelegate, SDWebImageManagerDelegate, NNDropDownMenuDelegate>
@property (nonatomic, unsafe_unretained) UIButton *navLeftButton;
@property (nonatomic, unsafe_unretained) UIButton *navRightButton;
@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) TTTAttributedLabel *slideShowTextLabel;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) UITableView *tableView;
@property (nonatomic, unsafe_unretained) CircleHeaderView *headerView;
@property (nonatomic, strong) NNDropDownMenu *dropDownMenu;

@property (nonatomic, strong) NSArray *menuTexts;
@property (nonatomic, strong) NSArray *menuIcons;

@property (nonatomic, strong) NSArray *channelTexts;
@property (nonatomic, strong) NSArray *channelTypes;
@property (nonatomic, assign) NSUInteger channelIndex;

@property (nonatomic, strong) MainSlideShowModel *slideShowModel;
@property (nonatomic, assign) SortType type;
@property (nonatomic, strong) id dataModel;// BabyListModel or CommonListModel;

- (UITableViewCell *)createHotListCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)createBabyCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)stringForType:(SortType)type;
- (contentType)judgeContentType:(id)item;

- (void)requestForSlideShow:(NSString *)channel;
- (void)requestForList:(NSString *)channel withListType:(SortType)type andRequestType:(requestType)requestType;
- (void)requestForVote:(NSString *)babyId withToken:(NSString *)token;

- (CGFloat)slideShowHeightForChannel:(NSUInteger)channelIndex;
- (void)updateTableView;
- (void)updateSlideShow;
- (void)onChannelChanged;
- (void)onSlideShowItemClicked:(UIView *)view;
- (void)enterControllerByType:(id)dataItem atOffset:(NSUInteger)offset;
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
    [navLeftButton setImage:[UIImage imageFromFile:@"icon_config_normal.png"] forState:UIControlStateNormal];
    UIImage *highlightedImage = [UIImage imageFromFile:@"icon_config_highlighted.png"];
    [navLeftButton setImage:highlightedImage forState:UIControlStateHighlighted];
    [navLeftButton setImage:highlightedImage forState:UIControlStateSelected];
    [navLeftButton addTarget:self action:@selector(toggleDropDownMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = self.navRightButton = [UIHelper createBarButton:5];
    [navRightButton setTitle:[self stringForType:_type] forState:UIControlStateNormal];
    [navRightButton addTarget:self action:@selector(switchListType) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    float layoutY = 0;
    
//    CircleHeaderView *headerView = self.headerView = [[CircleHeaderView alloc] initWithFrame:CGRectMake(0, layoutY, CompatibleScreenWidth, 30)];
//    headerView.delegate = self;
//    headerView.titles = self.channelTexts;
//    [headerView.carousel scrollToItemAtIndex:_channelIndex animated:NO];
//    [headerView reloadData];
//    [self.view addSubview:headerView];
    
    layoutY += 30;
    CGFloat slideShowHeight = [self slideShowHeightForChannel:_channelIndex];
    SlideShowView *slideShowView = self.slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, layoutY, CompatibleScreenWidth, slideShowHeight)];
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    slideShowView.clipsToBounds = YES;
    
    TTTAttributedLabel *slideShowTextLabel = self.slideShowTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, slideShowHeight - 16, CompatibleScreenWidth, 16)];
    slideShowTextLabel.textInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    slideShowTextLabel.clipsToBounds = YES;
    slideShowTextLabel.font = [UIFont systemFontOfSize:10];
    slideShowTextLabel.textColor = [UIColor whiteColor];
    slideShowTextLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    slideShowTextLabel.backgroundColor = RGBA(6, 6, 6, 0.7);
    [slideShowView addSubview:slideShowTextLabel];
    
    SMPageControl *pageControl = self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, slideShowHeight - 16, CompatibleScreenWidth - 10, 16)];
    pageControl.indicatorDiameter = 5;
    pageControl.indicatorMargin = 4;
    pageControl.currentPageIndicatorTintColor = HEXCOLOR(0x00a9ff);
    pageControl.alignment = SMPageControlAlignmentRight;
    pageControl.userInteractionEnabled = NO;
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [slideShowView addSubview:pageControl];
    
//    [self addObserver:self forKeyPath:@"slideShowView.frame" options:NSKeyValueObservingOptionOld context:NULL];
//    [self.view addSubview:slideShowView];
    
    CircleHeaderView *headerView = self.headerView = [[CircleHeaderView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 50)];
    headerView.delegate = self;
    headerView.titles = self.channelTexts;
    [headerView.carousel scrollToItemAtIndex:_channelIndex animated:NO];
    [headerView reloadData];
    [self.view addSubview:headerView];
    
//    layoutY += slideShowHeight;
    UITableView *tableView = self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, layoutY, CompatibleScreenWidth, CompatibleContainerHeight - layoutY) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = DarkThemeColor;
    tableView.tableHeaderView = slideShowView;
    tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [tableView addPullToRefreshWithActionHandler:^{
        // refresh data
        // call [tableView.pullToRefreshView stopAnimating] when done
        [self requestForSlideShow:[self.channelTypes objectAtIndex:_channelIndex]];
        [self requestForList:[self.channelTypes objectAtIndex:_channelIndex] withListType:_type andRequestType:requestTypeRefresh];
    }];
    [tableView addInfiniteScrollingWithActionHandler:^{
        // add data to data source, insert new cells into table view
        [self requestForList:[self.channelTypes objectAtIndex:_channelIndex] withListType:_type andRequestType:requestTypeAppend];
    }];
    tableView.showsInfiniteScrolling = NO;
    [self.view addSubview:tableView];
    
    [self addObserver:self forKeyPath:@"tableView.contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)cleanUp
{
    self.navLeftButton = nil;
    self.navRightButton = nil;
    
    if (_dropDownMenu) {
        self.dropDownMenu.menuDelegate = nil;
        self.dropDownMenu = nil;
    }
    
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
    
    self.slideShowModel = nil;
    self.dataModel = nil;
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

- (void)setType:(SortType)type {
    if (_type != type) {
        _type = type;
        [self.navRightButton setTitle:[self stringForType:type] forState:UIControlStateNormal];
        [_tableView.pullToRefreshView triggerRefresh];
    }
}

- (NSArray *)channelTexts {
    if (!_channelTexts) {
        _channelTexts = [NSArray arrayWithObjects:@"首页", @"知道", @"爱玩", @"视频", @"精选", @"女人", nil];
    }
    
    return  _channelTexts;
}

- (NSArray *)channelTypes {
    if (!_channelTypes) {
        _channelTypes = [NSArray arrayWithObjects:@"home", @"know", @"play", @"video", @"top", @"women", nil];
    }
    
    return _channelTypes;
}

- (NSArray *)menuTexts {
    if (!_menuTexts) {
        _menuTexts = @[@"清除缓存", @"意见反馈", @"关于我们", @"登录"];
    }
    
    return _menuTexts;
}

- (NSArray *)menuIcons {
    if (!_menuIcons) {
        _menuIcons = @[@"icon_clear_normal.png", @"icon_feedback_normal.png", @"icon_about_normal.png", @"icon_sign_normal.png"];
    }
    
    return _menuIcons;
}

- (NNDropDownMenu *)dropDownMenu {
    if (!_dropDownMenu) {
        _dropDownMenu = [[NNDropDownMenu alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, CompatibleScreenHeight)];
        _dropDownMenu.topPadding = NavBarHeight + StatusBarHeight;
        _dropDownMenu.itemHeight = 40;
        _dropDownMenu.menuDelegate = self;
        
        [self.menuTexts enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL *stop) {
            NNMenuItem *item = [[NNMenuItem alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 40)];
            [item setText:text withColor:[UIColor whiteColor] andHighlightedColor:[UIColor darkGrayColor]];
            UIImage *iconImage = [UIImage imageFromFile:self.menuIcons[idx]];
            [item setIconImage:iconImage andHighlightedImage:[iconImage opacity:0.5]];
            [_dropDownMenu addItem:item];
        }];
        
        __unsafe_unretained MainController *weakSelf = self;
        __unsafe_unretained NNDropDownMenu *weakMenu = _dropDownMenu;
        _dropDownMenu.onItemClicked = ^(NNMenuItem *item, NSUInteger index) {
            switch (index) {
                case 0: //清除缓存
                    [weakSelf clearCache];
                    break;
                    
                case 1: //意见反馈
                    [weakSelf showFeedbackController];
                    break;
                    
                case 2: //关于我们
                    [weakSelf showAboutController];
                    break;

                case 3: //登陆注销
                    [weakSelf sign];
                    break;
            }
            
            if ([weakMenu isKindOfClass:[NNDropDownMenu class]]) {
                [weakMenu dismissMenu];
            }
        };
    }
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    BOOL tokenAvailable = [sessionManager getToken] || [sessionManager canAutoLogin];
    NNMenuItem *signItem = _dropDownMenu.items[3];
    [signItem setText:tokenAvailable ? @"注销" : @"登录"];
    
    return _dropDownMenu;
}

#pragma mark - UIViewController life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self updateUserStatus];
    
    [_headerView.carousel scrollToItemAtIndex:_channelIndex animated:NO];
    
    if (_slideShowView.carousel.currentItemIndex < 1) {
        [self.slideShowView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.slideShowView startAutoScroll:2];
    
    if (!_dataModel || !_slideShowModel) {
        [_tableView.pullToRefreshView triggerRefresh];
    }
//    else {
//        [_tableView reloadData];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.slideShowView stopAutoScroll];
}


#pragma mark - SlideShowViewDataSource methods

- (NSUInteger)numberOfItemsInSlideShowView:(SlideShowView *)slideShowView {
    NSUInteger count = !_slideShowModel ? MainSlideShowCount : _slideShowModel.list.count;
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
    
    [((UIImageView *)view) setImage:[UIImage imageNamed:(_headerView.currentItemIndex == kBabyChannelIndex ?
                                                         @"img_baby_slide_show_place_holder.png" :
                                                         @"img_common_slide_show_place_holder.png")]];
    
    if (_slideShowModel.list) {
        NSString *imgUrl = [[_slideShowModel.list objectAtIndex:index] imgUrl];
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:imgUrl]
                                                  delegate:self
                                                   options:0
                                                   success:^(UIImage *image, BOOL cached)
         {
             UIImage *cropedImage = [[image scaleByFactor:view.frame.size.width / image.size.width] cropToSize:view.frame.size usingMode:NYXCropModeTopCenter];
             [((UIImageView *)view) setImage:cropedImage];
         }
                                                   failure:nil];
    }
    
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
    return _channelIndex == kBabyChannelIndex ? 80 : 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id dataItem = [[_dataModel items] objectAtIndex:indexPath.row];
    [self enterControllerByType:dataItem atOffset:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CircleHeaderViewDelegate methods

- (void)currentItemIndexDidChange:(CircleHeaderView *)headView {
    _tableView.dataSource = nil;
    [[NNHttpClient sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:@"image_list"];
    [[NNHttpClient sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:@"work_list"];
    [_tableView.pullToRefreshView stopAnimating];
    [_tableView.infiniteScrollingView stopAnimating];
    
    [_slideShowView stopAutoScroll];
    
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
    navController.logoHidden = NO;
    controller.videoUrl = videoUrl;
    [self.navigationController presentModalViewController:navController animated:YES];
}

#pragma mark - NNDropDownMenuDelegate methods

- (void)onMenuDismissed {
    self.navLeftButton.selected = NO;
}

#pragma mark - Private methods

- (NSString *)stringForType:(SortType)type {
    if (type == SortTypeLatest) {
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

- (NSString *)requestStringForType:(SortType)type {
    if (type == SortTypeLatest) {
        return @"new";
    }
    
    return @"hot";
}

- (void)switchListType {
    SortType newType = _type == SortTypeLatest ? SortTypeHotest : SortTypeLatest;
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

- (void)sign {
    SessionManager *sessionManager = [SessionManager sharedManager];
    BOOL tokenAvailable = [sessionManager getToken] || [sessionManager canAutoLogin];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:tokenAvailable ? @selector(signOut) : @selector(signIn)];
#pragma clang diagnostic pop
}

- (void)signIn {
    [[SessionManager sharedManager] requsetToken:self success:nil];
}

- (void)signOut {
    RIButtonItem *cancelItem = [RIButtonItem item];
    cancelItem.label = @"取消";
    
    RIButtonItem *okItem = [RIButtonItem item];
    okItem.label = @"确定";
    okItem.action = ^
    {
        [[SessionManager sharedManager] signOut];
//        [self updateUserStatus];
    };
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"确定注销？"
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:okItem, nil];
    [alertView show];
}

- (void)showAboutController {
    AboutController *controller = [[AboutController alloc] init];
    NNNavigationController *navController = [[NNNavigationController alloc] initWithRootViewController:controller];
    navController.logoHidden = NO;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

- (void)showFeedbackController {
    FeedbackController *controller = [[FeedbackController alloc] init];
    NNNavigationController *navController = [[NNNavigationController alloc] initWithRootViewController:controller];
    navController.logoHidden = NO;
    
    [self.navigationController presentModalViewController:navController animated:YES];
}

- (void)clearCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    });
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
    }];
}

- (void)requestForList:(NSDictionary *)parameters withRequestType:(requestType)requestType {
    BOOL isBabyChannel = [[parameters objectForKey:@"channel"] isEqualToString:@"baby"];
    NSString *path = @"work_list";
    Class responseClass = isBabyChannel ? [BabyListModel class] : [CommonListModel class];
    
    [[NNHttpClient sharedClient] getAtPath:path parameters:parameters responseClass:responseClass success:^(id<Jsonable> response) {
        if (isBabyChannel == (_channelIndex == kBabyChannelIndex)) {
            if (requestType == requestTypeAppend) {
                [self.dataModel appendMoreData:response];
            } else {
                self.dataModel = response;
            }
            
            [self updateTableView];
        }
        
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
        [_tableView.pullToRefreshView stopAnimating];
        [_tableView.infiniteScrollingView stopAnimating];
    }];
 
}

- (void)requestForList:(NSString *)channel withListType:(SortType)type andRequestType:(requestType)requestType {
    NSUInteger offset = (requestType == requestTypeRefresh ? 0 : [_dataModel items].count);
    BOOL isBabyChannel = [channel isEqualToString:@"baby"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:channel, @"channel",
                                [self requestStringForType:type], @"sort_type",
                                [NSString stringWithFormat:@"%u", offset], @"offset",
                                kRequestCountString, @"count", @"true", @"filter", nil];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    if (isBabyChannel && ([sessionManager getToken] || [sessionManager canAutoLogin])) {
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
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:dataItem.thumbUrl] placeholderImage:[UIImage imageNamed:@"img_common_list_place_holder.png"]];
    cell.titleLabel.text = dataItem.title;
    cell.descriptionLabel.text = dataItem.readableContentType;
    cell.dateLabel.text = dataItem.date;
    
    return cell;
}

- (UITableViewCell *)createBabyCell:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString *babyCellIdentifier = @"BabyCell";
    
    BabyCell *cell = [tableView dequeueReusableCellWithIdentifier:babyCellIdentifier];
    if (!cell) {
        cell = [[BabyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:babyCellIdentifier];
        cell.delegate = self;
    } else {
        [cell reset];
    }
    
    BabyItem *dataItem = [[_dataModel items] objectAtIndex:indexPath.row];
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:dataItem.photoUrl] placeholderImage:[UIImage imageNamed:@"img_baby_photo_place_holder.png"]];
    cell.titleLabel.text = dataItem.babyName;
    cell.scoreLabel.text = [NSString stringWithFormat:@"%u票", dataItem.voteNum];
    cell.videoShots = dataItem.videoShots;
    cell.videoUrls = dataItem.videoUrls;
    cell.voted = dataItem.voted;
    cell.tag = indexPath.row;
    
    return cell;
}

- (CGFloat)slideShowHeightForChannel:(NSUInteger)channelIndex {
    switch (channelIndex) {
        case kBabyChannelIndex:
            return 110;
        
        case kTopChannelIndex:
            return 0;
            
        default:
            return 150;
    }
}

//- (void)updateUserStatus {
//    SessionManager *sessionManager = [SessionManager sharedManager];
//    BOOL tokenAvailable = [sessionManager getToken] || [sessionManager canAutoLogin];
//    
//    [self.navLeftButton setImage:(tokenAvailable ? [UIImage imageFromFile:@"icon_config_highlighted.png"] :
//                                  [UIImage imageFromFile:@"icon_config_normal.png"])
//                        forState:UIControlStateNormal];
//    
//    [self.navLeftButton removeTarget:nil
//                       action:NULL
//             forControlEvents:UIControlEventAllEvents];
//    [self.navLeftButton addTarget:self
//                           action:(tokenAvailable ? @selector(signOut) : @selector(signIn))
//                 forControlEvents:UIControlEventTouchUpInside];
//}

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
    _tableView.dataSource = self;
    
    self.dataModel = nil;
    [_tableView reloadData];
    
    self.slideShowModel = nil;
    [_slideShowView reloadData];
    
    self.channelIndex = _headerView.carousel.currentItemIndex;
    
    [self requestForSlideShow:[self.channelTypes objectAtIndex:_channelIndex]];
    [_tableView.pullToRefreshView triggerRefresh];
    
    CGRect frame = _slideShowView.frame;
    frame.size.height = [self slideShowHeightForChannel:_channelIndex];
    _slideShowView.frame = frame;
    _tableView.tableHeaderView = _slideShowView;
    
    [_slideShowView startAutoScroll:2];
}

- (void)enterControllerByType:(id)dataItem atOffset:(NSUInteger)offset{
    id controller;
    
    switch ([self judgeContentType:dataItem]) {
        case contentTypeArticle:
            controller = [[ArticleDetailController alloc] init];
            [controller setContentId:[dataItem contentId]];
            [controller setContentTitle:[dataItem title]];
            [controller setSortType:_type];
            [controller setOffset:offset];
            [controller setChannel:[self.channelTypes objectAtIndex:_channelIndex]];
            break;
            
        case contentTypeSlide:
            controller = [[BabyDetailController alloc] init];
            [controller setContentType:[dataItem contentType]];
            [controller setContentId:[dataItem contentId]];
            [controller setSortType:_type];
            [controller setOffset:offset];
            [controller setChannel:[self.channelTypes objectAtIndex:_channelIndex]];
            
            if ([dataItem isKindOfClass:[BabyItem class]]) {
                [controller setVoted:[dataItem voted]];
                [controller setContentTitle:[dataItem babyName]];
            } else {
                [controller setContentTitle:[dataItem title]];
            }
            break;
            
        case contentTypeVideo:
            controller = [[VideoPlayController alloc] init];
            [controller setVideoUrl:[dataItem videoUrl]];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onSlideShowItemClicked:(UIGestureRecognizer *)recognizer {
    NSInteger index = recognizer.view.tag;
    
    [self enterControllerByType:[_slideShowModel.list objectAtIndex:index] atOffset:0];
}

- (void)toggleDropDownMenu {
    self.navLeftButton.selected = YES;
    [self.dropDownMenu showMenu];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if([keyPath isEqualToString:@"slideShowView.frame"]) {
//        CGRect oldFrame = CGRectNull;
//        CGRect newFrame = CGRectNull;
//        if([change objectForKey:@"old"] != [NSNull null]) {
//            oldFrame = [[change objectForKey:@"old"] CGRectValue];
//        }
//        if([object valueForKeyPath:keyPath] != [NSNull null]) {
//            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
//        }
//        
//        CGFloat delta = newFrame.size.height - oldFrame.size.height;
//        
//        CGRect frame = self.tableView.frame;
//        frame.origin.y += delta;
//        frame.size.height -= delta;
//        self.tableView.frame = frame;
//    }
    if ([keyPath isEqualToString:@"tableView.contentOffset"]) {
        if (_tableView.contentOffset.y > [self slideShowHeightForChannel:_channelIndex] || _tableView.isDragging) {
            [_slideShowView stopAutoScroll];
        } else {
            [_slideShowView startAutoScroll:2];
        }
    }
}

@end
