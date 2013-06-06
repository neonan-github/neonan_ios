//
//  GalleryDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "GalleryDetailController.h"
#import "NNNavigationController.h"

#import "SlideShowDetailModel.h"
#import "NearWorksModel.h"

#import "EncourageHelper.h"
#import "ShareHelper.h"
#import "SessionManager.h"

#import "SMPageControl.h"
#import "EncourageView.h"
#import "FunctionFlowView.h"
#import "GalleryOverView.h"
#import "GalleryOverViewCell.h"

#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

static const float kDescriptionShrinkedLines = 4;
static const float kDescriptionStretchedLines = 7;

static const CGFloat kTitleLabelOriginalHeight = 30;

static const NSUInteger kTagSSImageView = 1000;
static const NSUInteger kTagSSprogressView = 1001;

@interface GalleryDetailController () <SlideShowViewDataSource, SlideShowViewDelegate,
FoldableTextBoxDelegate, UIScrollViewDelegate, KKGridViewDataSource, KKGridViewDelegate>

@property (nonatomic, unsafe_unretained) UIView *titleBox;
@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UIButton *likeButton;
@property (nonatomic, unsafe_unretained) UIButton *actionButton;

@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) FoldableTextBox *textBox;
@property (nonatomic, weak) GalleryOverView *overView;
@property (nonatomic, readonly) FunctionFlowView *moreActionView;

@property (nonatomic, strong) UIActivityIndicatorView *progressView;

@property (nonatomic, strong) ShareHelper *shareHelper;

@property (nonatomic, strong) SlideShowDetailModel *dataModel;

@property (nonatomic, unsafe_unretained) CALayer *cacheLayer;
@property (nonatomic, assign) BOOL isAnimating;

// 放大后的图片可能滚动到边界的判断条件
@property (nonatomic, assign) CGFloat zoomDragBeginX;
@property (nonatomic, assign) CGFloat zoomDragBeginY;

- (void)requestForSlideShow;
- (void)requestForVote:(NSString *)babyId withToken:(NSString *)token;
- (void)showProgressView;

- (void)updateData;
@end

@implementation GalleryDetailController
@synthesize moreActionView = _moreActionView;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton* backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    SlideShowView *slideShowView = self.slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, -NavBarHeight, CompatibleScreenWidth, CompatibleScreenHeight - StatusBarHeight)];
    slideShowView.wrap = NO;
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    slideShowView.backgroundColor = DarkThemeColor;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [slideShowView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:slideShowView];
    
    UIImageView *navBottomLine = [[UIImageView alloc] initWithImage:[UIImage imageFromFile:@"img_nav_bottom_line.png"]];
    CGRect frame = navBottomLine.frame;
    frame.origin.y = -4;
    navBottomLine.frame = frame;
    
    UILabel *titleLabel = self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 250, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = [UIFont systemFontOfSize:13];
    
    UIButton *likeButton = self.likeButton = [[UIButton alloc] initWithFrame:CGRectMake(245, 5, 35, 25)];
    likeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
//    likeButton.backgroundColor = RGBA(255, 0, 0, 0.3);
    [likeButton setImage:[UIImage imageFromFile:@"icon_love_normal.png"] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageFromFile:@"icon_love_highlighted.png"] forState:UIControlStateHighlighted];
    [likeButton setImage:[UIImage imageFromFile:@"icon_love_highlighted.png"] forState:UIControlStateDisabled];
    [likeButton addTarget:self action:@selector(vote) forControlEvents:UIControlEventTouchUpInside];
    likeButton.enabled = !_voted;
    likeButton.hidden = ![_contentType isEqualToString:@"baby"];
    
    UIButton *actionButton = self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 2, 40, 38)];
    actionButton.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 0);
//    shareButton.backgroundColor = RGBA(0, 255, 0, 0.3);
    [actionButton setImage:[UIImage imageFromFile:@"icon_over_flow_normal.png"] forState:UIControlStateNormal];
    [actionButton setImage:[UIImage imageFromFile:@"icon_over_flow_highlighted.png"] forState:UIControlStateHighlighted];
    [actionButton addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *titleBox = self.titleBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 35)];
    titleBox.backgroundColor = DarkThemeColor;
    titleBox.clipsToBounds = YES;
    [titleBox addSubview:navBottomLine];
    [titleBox addSubview:titleLabel];
    [titleBox addSubview:likeButton];
    [titleBox addSubview:actionButton];
    [self.view addSubview:titleBox];
    
    frame = CGRectMake(0, CompatibleContainerHeight - 32, CompatibleScreenWidth, 0);
    FoldableTextBox *textBox = self.textBox = [[FoldableTextBox alloc] initWithFrame:frame];
    frame.size.height = [textBox getSuggestedHeight];
    textBox.frame = frame;
    textBox.delegate = self;
    textBox.insets = UIEdgeInsetsMake(0, 10, 25, 20);
    [self.view addSubview:textBox];
    
    SMPageControl *pageControl = self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, CompatibleContainerHeight - 18, CompatibleScreenWidth, 16)];
    pageControl.indicatorDiameter = 5;
    pageControl.indicatorMargin = 4;
    pageControl.currentPageIndicatorTintColor = HEXCOLOR(0x00a9ff);
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    
    GalleryOverView *overView = [[GalleryOverView alloc] initWithFrame:self.view.bounds];
    self.overView = overView;
    overView.gridView.dataSource = self;
    overView.gridView.delegate = self;
    [self.view addSubview:overView];
}

- (void)cleanUp {
    self.cacheLayer = nil;
    
    self.titleLabel = nil;
    self.likeButton = nil;
    self.actionButton = nil;
    self.titleBox = nil;
    
    self.overView.gridView.dataSource = nil;
    self.overView.gridView.delegate = nil;
    self.overView = nil;
    
    self.slideShowView.dataSource = nil;
    self.slideShowView.delegate = nil;
    self.slideShowView = nil;
    
    self.pageControl = nil;
    
    self.textBox.delegate = nil;
    self.textBox = nil;
    
    self.progressView = nil;
    
    self.dataModel = nil;
    
    self.shareHelper = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.overView.frame = self.view.bounds;
    self.overView.expanded = NO;
    
    if (!_dataModel) {
        [self requestForSlideShow];
    }
    
    [self adjustLayout:_contentTitle];
    _titleLabel.text = _contentTitle;
    _textBox.expanded = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - UIScrollViewDelegate methods for Image Zoom

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (ABS(_zoomDragBeginY - contentOffsetY) > ABS(_zoomDragBeginX - contentOffsetX)) {
        return;
    }
    
    NSInteger toIndex = 0;
    
    iCarousel *carousel = _slideShowView.carousel;
    
    if (_zoomDragBeginX < 1 && contentOffsetX <= _zoomDragBeginX) {
        toIndex = carousel.currentItemIndex - 1;
    } else if (_zoomDragBeginX > scrollView.contentSize.width - [scrollView viewWithTag:kTagSSImageView].bounds.size.width - 1 &&
               contentOffsetX >= _zoomDragBeginX) {
        toIndex = carousel.currentItemIndex + 1;
    } else {
        return;
    }
    
    scrollView.scrollEnabled = NO;
    scrollView.scrollEnabled = YES;
    if (toIndex < 0 || toIndex >= carousel.numberOfItems) {
        [self slideShowView:_slideShowView overSwipWithDirection:toIndex < 0 ? UISwipeGestureRecognizerDirectionRight : UISwipeGestureRecognizerDirectionLeft];
    } else {
        [carousel scrollToItemAtIndex:toIndex animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.zoomDragBeginX = scrollView.contentOffset.x;
    self.zoomDragBeginY = scrollView.contentOffset.y;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView viewWithTag:kTagSSImageView];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIImageView *imageView = (UIImageView *)[scrollView viewWithTag:kTagSSImageView];
    
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = imageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(imageView.frame, frameToCenter))
		imageView.frame = frameToCenter;
}

#pragma mark - SlideShowViewDataSource methods

- (NSUInteger)numberOfItemsInSlideShowView:(SlideShowView *)slideShowView {
    NSUInteger count = _dataModel.imgUrls.count;
    [self.overView setCurrentPage:slideShowView.carousel.currentItemIndex + 1 totalPage:count];
    [self.pageControl setNumberOfPages:count];
    return count;
}

- (UIView *)slideShowView:(SlideShowView *)slideShowView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:slideShowView.bounds];
        imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = kTagSSImageView;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:slideShowView.bounds];
        scrollView.backgroundColor = DarkThemeColor;
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
//        scrollView.scrollEnabled = NO;
//        scrollView.contentSize = imageView.frame.size;
        scrollView.minimumZoomScale = 0.5;
        scrollView.maximumZoomScale = 3.0;
        [scrollView addSubview:imageView];
        view = scrollView;
        
        UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        progressView.tag = kTagSSprogressView;
        
        CGRect frame = progressView.frame;
        frame.origin.x = (slideShowView.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = (slideShowView.bounds.size.height - frame.size.height) / 2;
        progressView.frame = frame;
        [view addSubview:progressView];
    }
    
    __weak UIImageView *imageView = (UIImageView *)[view viewWithTag:kTagSSImageView];
    UIActivityIndicatorView *progressView = (UIActivityIndicatorView *)[view viewWithTag:kTagSSprogressView];
    NSURL *imgUrl = [NSURL URLWithString:[_dataModel.imgUrls objectAtIndex:index]];
    [imageView setImageWithURL:imgUrl success:^(UIImage *image, BOOL cached) {
        CGRect frame = imageView.frame;
        frame.size.height = image.size.height / image.size.width * frame.size.width;
        frame.origin.y = (view.bounds.size.height - frame.size.height) / 2;
        imageView.frame = frame;
        
        ((UIScrollView *)view).contentSize = imageView.bounds.size;
        
        [progressView stopAnimating];
    } failure:nil];
    
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:[imgUrl absoluteString]];
    if (cachedImage) {
        [progressView stopAnimating];
    } else {
        [progressView startAnimating];
    }
    
    return view;
}

#pragma mark - SlideShowViewDelegate methods

- (void)slideShowViewItemIndexDidChange:(SlideShowView *)slideShowView {
    NSUInteger currentIndex = slideShowView.carousel.currentItemIndex;
    NSArray *visibleItems = slideShowView.carousel.visibleItemViews;
    for (UIScrollView *scrollView in visibleItems) {
        [UIView beginAnimations:nil context:nil];
        scrollView.zoomScale = 1.0;
        [UIView commitAnimations];
    }
    [self.pageControl setCurrentPage:currentIndex];
    [self.overView setCurrentPage:currentIndex + 1 totalPage:slideShowView.carousel.numberOfItems];
    
    NSArray *descriptions = _dataModel.descriptions;
    if (descriptions) {
        self.overView.textView.text = descriptions[descriptions.count > 1 ? currentIndex : 0];
    }
}

- (void)slideShowView:(SlideShowView *)slideShowView overSwipWithDirection:(UISwipeGestureRecognizerDirection)direction {
    if (_isAnimating || !_dataModel || self.overView.expanded) {
        return;
    }
    
    BOOL next = direction == UISwipeGestureRecognizerDirectionLeft;
    
//    if ((_currentIndex >= _maxIndex && next) || (_currentIndex < 1 && !next)) {// 到头或尾
//        [self performBounce:!next];
//        return;
//    }
    
//    self.currentIndex += next ? 1 : -1;
    
    [self fetchDetailInfo:^(NSString *token) {
        [self requestNearSlideShow:next contentId:_contentId token:token success:^{
            self.isAnimating = YES;
            
            CGFloat viewWidth = self.view.frame.size.width;
            CGFloat viewHeight = self.view.frame.size.height;
            
            CALayer *cacheLayer = self.cacheLayer = [CALayer layer];
            UIImage *cacheImage = [UIImage imageFromView:self.view];
            cacheLayer.frame = CGRectMake((next ? -1 : 1) * viewWidth, 0, viewWidth, viewHeight);
            cacheLayer.contents = (id)cacheImage.CGImage;
            [self.view.layer insertSublayer:cacheLayer above:self.view.layer];

            [self clearContents];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            //    animation.duration = 5;
            animation.delegate = self;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake((next ? 1.5f : -0.5f) * viewWidth, viewHeight / 2)];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(viewWidth / 2, viewHeight / 2)];
            [self.view.layer addAnimation:animation forKey:@"position"];
        }];
    }];
}

#pragma mark - KKGridViewDataSource methods

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section {
    return self.dataModel.imgUrls.count;
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    GalleryOverViewCell * cell = (GalleryOverViewCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[GalleryOverViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 59.0, 59.0) reuseIdentifier:CellIdentifier];
    }
    
    [cell.imageView setImageWithURL:[URLHelper imageURLWithString:self.dataModel.imgUrls[indexPath.index]]
                   placeholderImage:nil];
    
    return cell;
}

#pragma mark - KKGridViewDelegate methods

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath {
    [gridView deselectAll:YES];
    [self.slideShowView.carousel scrollToItemAtIndex:indexPath.index animated:NO];
    [self.overView setExpanded:NO animated:YES];
}

#pragma mark - FoldableTextBoxDelegate methods

- (void)onFrameChanged:(CGRect)frame {
    frame.origin.y = self.navigationController.navigationBarHidden ? (CompatibleScreenHeight - StatusBarHeight) : (CompatibleContainerHeight - frame.size.height);
    self.textBox.frame = frame;
}

#pragma mark - Private methods

- (void)tap:(UITapGestureRecognizer *)recognizer {
    BOOL hidden = !self.navigationController.navigationBarHidden;
    
    [UIView beginAnimations:nil context:nil];
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
    
    CGRect frame = self.slideShowView.frame;
    frame.origin.y = hidden ? 0 : -NavBarHeight;
    self.slideShowView.frame = frame;
    
    frame = self.titleBox.frame;
    frame.origin.y = hidden ? -frame.size.height : 0;
    self.titleBox.frame = frame;
    
    frame = self.textBox.frame;
    frame.origin.y = hidden ? (CompatibleScreenHeight - StatusBarHeight) : (CompatibleContainerHeight - frame.size.height);
    self.textBox.frame = frame;
//    方法一
//    frame = self.pageControl.frame;
//    frame.origin.y = hidden ? (390 + 44) : 390;
//    self.pageControl.frame = frame;
    //方法二
    self.pageControl.transform = CGAffineTransformMakeTranslation(0, hidden ? NavBarHeight : 0);
    [UIView commitAnimations];
}

- (FunctionFlowView *)moreActionView {
    if (!_moreActionView) {
        _moreActionView = [[FunctionFlowView alloc] initWithFrame:CGRectMake(245, 40, 68, 53)];
        [_moreActionView.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        [_moreActionView.favButton addTarget:self action:@selector(doFav) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _moreActionView;
}

- (IBAction)showMoreAction:(id)sender {
    [self.view addSubview:self.moreActionView];
}

- (void)doFav {
    if (!_dataModel) {
        return;
    }
    
    BOOL up = !_dataModel.favorited;
    
    [self requestFavorites:[_contentId description] up:up];
}

- (void)share {
    if (!_dataModel) {
        return;
    }
    
    if (!self.shareHelper) {
        self.shareHelper = [[ShareHelper alloc] initWithRootViewController:self];
    }
    
    _shareHelper.shareText = [_contentType isEqualToString:@"baby"] ? [NSString stringWithFormat:@"牛男宝贝 %@", _dataModel.title]: _dataModel.title;
    _shareHelper.shareUrl = _dataModel.shareUrl;
    _shareHelper.shareImage = [[SDImageCache sharedImageCache] imageFromKey:_dataModel.imgUrls[_slideShowView.carousel.currentItemIndex]];
    [_shareHelper showShareView];
}

- (void)vote {
    SessionManager *sessionManager = [SessionManager sharedManager];
    NSString *babyId = _contentId;
    [sessionManager requsetToken:self success:^(NSString *token) {
        [self requestForVote:babyId withToken:token];
    }];
}

- (void)onDetailFetched:(id<Jsonable>)response {
    self.dataModel = response;
    NSString *contentId = _dataModel.contentId;
    _contentId = _dataModel.contentId;
    
    Record *record = [[Record alloc] init];
    record.contentType = _contentType;
    record.contentId = _contentId;
    [[HistoryRecorder sharedRecorder] saveRecord:record];
    
    __weak GalleryDetailController *weakSelf = self;
    [EncourageHelper check:_contentId contentType:_contentType afterDelay:5
                    should:^BOOL{
                        return [[contentId description] isEqualToString:[_contentId description]] &&
                        [[SessionManager sharedManager] canAutoLogin] && [weakSelf isVisible];
                    }
                   success:^(NSInteger point) {
                       [EncourageView displayScore:point at:CGPointMake(CompatibleScreenWidth / 2, 100)];
                   }];
    
    [self updateData];
}

#pragma mark - Private Request methods

- (void)fetchDetailInfo:(void (^)(NSString *token))requestBlock {
    [self showProgressView];
    
    if ([[SessionManager sharedManager] canAutoLogin]) {
        [[SessionManager sharedManager] requsetToken:self success:^(NSString *token) {
            requestBlock(token);
        }];
        
        return;
    }
    
    requestBlock(nil);
}

- (void)requestNearSlideShow:(BOOL)next contentId:(NSString *)contentId token:(NSString *)token success:(void (^)())success {
    NSMutableDictionary *parameters = [@{@"sort_type": _sortType == SortTypeHotest ? @"hot" : @"new",
                                       @"channel": _channel, @"content_type": _contentType,
                                       @"content_id": _contentId, @"direction": @(next ? 1 : -1)} mutableCopy];
    if (token) {
        [parameters setObject:token forKey:@"token"];
    }
    
    [[NNHttpClient sharedClient] getAtPath:kPathNearWork
                                parameters:parameters
                             responseClass:[SlideShowDetailModel class]
                                   success:^(id<Jsonable> response) {
                                       if (response) {
                                           [_progressView removeFromSuperview];
                                           
                                           if (success) {
                                               success();
                                           }
                                           
                                           [self onDetailFetched:response];
                                       } else {
                                           [_progressView removeFromSuperview];
                                           [self performBounce:!next];
                                       }
                                   }
                                   failure:^(ResponseError *error) {
                                       DLog(@"error:%@", error.message);
                                       if (self.isVisible) {
                                           [UIHelper alertWithMessage:error.message];
                                       }
                                   }];
}

- (void)requestForSlideShowWithParams:(NSDictionary *)parameters success:(void (^)())success {
    [[NNHttpClient sharedClient] getAtPath:kPathWorkInfo parameters:parameters responseClass:[SlideShowDetailModel class] success:^(id<Jsonable> response) {
        [self onDetailFetched:response];
        
        if (success) {
            success();
        }
    } failure:^(ResponseError *error) {
        DLog(@"error:%@", error.message);
        if (self.isVisible) {
            [UIHelper alertWithMessage:error.message];
        }
    }];
}

- (void)requestForSlideShow {
    [self showProgressView];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:_contentType, @"content_type",
                                _contentId, @"content_id", nil];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    if ([sessionManager canAutoLogin]) {
        [sessionManager requsetToken:self success:^(NSString *token) {
            [parameters setValue:token forKey:@"token"];
            [self requestForSlideShowWithParams:parameters success:^{
                [_progressView removeFromSuperview];
            }];
        }];
    } else {
        [self requestForSlideShowWithParams:parameters success:^{
            [_progressView removeFromSuperview];
        }];
    }
}

- (void)requestForVote:(NSString *)babyId withToken:(NSString *)token {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:babyId, @"content_id",
                                token, @"token", nil];
    
    [[NNHttpClient sharedClient] postAtPath:@"api/baby_vote" parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
        if ([self isViewLoaded]) {
            _dataModel.voted = YES;
            [self updateData];
        }
    } failure:^(ResponseError *error) {
        DLog(@"error:%@", error.message);
        if (self.isVisible) {
            [UIHelper alertWithMessage:error.message];
        }
    }];
}

- (void)requestFavorites:(NSString *)contentId up:(BOOL)up {
    SessionManager *sessionManager = [SessionManager sharedManager];
    [sessionManager requsetToken:self success:^(NSString *token) {
        NSDictionary *parameters = up ? @{@"token": token, @"content_id": contentId} : @{@"token": token, @"content_id": contentId, @"cancel": @"true"};
        
        [[NNHttpClient sharedClient] postAtPath:kPathDoFav parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
            if ([contentId isEqualToString:[_contentId description]]) {
                _dataModel.favorited = up;
                self.moreActionView.favorited = up;
            }
            
        } failure:^(ResponseError *error) {
            DLog(@"error:%@", error.message);
        }];
    }];
}

#pragma mark - Private UI related

- (void)showProgressView {
    if (!_progressView) {
        UIActivityIndicatorView *progressView = self.progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect frame = progressView.frame;
        frame.origin.x = (_slideShowView.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = (_slideShowView.bounds.size.height - frame.size.height) / 2;
        progressView.frame = frame;
    }
    
    if (!_progressView.superview) {
        [_slideShowView addSubview:_progressView];
        [_progressView startAnimating];
    }
}

- (CGFloat)adjustLayout:(NSString *)title {
    CGFloat titleOriginalHeight = _titleLabel.frame.size.height;
    CGFloat titleAdjustedHeight = [UIHelper computeHeightForLabel:_titleLabel withText:title];
    CGFloat delta = titleAdjustedHeight - titleOriginalHeight;
    
    CGRect frame = _titleLabel.frame;
    frame.size.height = titleAdjustedHeight;
    _titleLabel.frame = frame;
    
    frame = _titleBox.frame;
    frame.size.height += delta;
    _titleBox.frame = frame;

    return delta;
}

- (void)updateData {
    [_slideShowView reloadData];
    [self slideShowViewItemIndexDidChange:_slideShowView];
    
    _likeButton.enabled = !_dataModel.voted;
    
    [self adjustLayout:_dataModel.title];
    _titleLabel.text = self.contentTitle = _dataModel.title;
    _titleLabel.hidden = NO;
    
    self.moreActionView.favorited = _dataModel.favorited;
    
    [self.overView.gridView reloadData];
}

- (void)clearContents {
    self.dataModel = nil;
    
    _titleLabel.hidden = YES;
    _likeButton.enabled = YES;
    
    [_slideShowView reloadData];
    
    _textBox.text = @"";
}

- (void)performBounce:(BOOL)left {
    CAAnimation *animation = [UIHelper createBounceAnimation:left ? NNDirectionLeft : NNDirectionRight];
    [CATransaction begin];
    [self.view.layer addAnimation:animation forKey:@"bounceAnimation"];
    [CATransaction commit];
}

#pragma mark - CAAnimationDelegate methods

- (void)animationDidStart:(CAAnimation *)anim {
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.isAnimating = !flag;
    [self.cacheLayer removeAllAnimations];
    [self.cacheLayer removeFromSuperlayer];
}

@end
