//
//  BabyDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyDetailController.h"
#import "NNNavigationController.h"
#import "SMPageControl.h"
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

#import "SlideShowDetailModel.h"
#import "NearWorksModel.h"
#import "ShareHelper.h"

static const float kDescriptionShrinkedLines = 4;
static const float kDescriptionStretchedLines = 7;

static const CGFloat kTitleLabelOriginalHeight = 30;

static const NSUInteger kTagSSImageView = 1000;
static const NSUInteger kTagSSprogressView = 1001;

@interface BabyDetailController () <SlideShowViewDataSource, SlideShowViewDelegate,
FoldableTextBoxDelegate, UIScrollViewDelegate>

@property (nonatomic, unsafe_unretained) UIView *titleBox;
@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UIButton *likeButton;
@property (nonatomic, unsafe_unretained) UIButton *shareButton;

@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) FoldableTextBox *textBox;

@property (nonatomic, strong) UIActivityIndicatorView *progressView;

@property (nonatomic, strong) ShareHelper *shareHelper;

@property (nonatomic, strong) SlideShowDetailModel *dataModel;
@property (nonatomic, strong) NearWorksModel *idModel;
@property (nonatomic, assign) NSInteger idIndex;

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

@implementation BabyDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
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
    
    UIButton *shareButton = self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(285, 5, 35, 25)];
    shareButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 10);
//    shareButton.backgroundColor = RGBA(0, 255, 0, 0.3);
    [shareButton setImage:[UIImage imageFromFile:@"icon_share.png"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *titleBox = self.titleBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 35)];
    titleBox.backgroundColor = DarkThemeColor;
    titleBox.clipsToBounds = YES;
    [titleBox addSubview:navBottomLine];
    [titleBox addSubview:titleLabel];
    [titleBox addSubview:likeButton];
    [titleBox addSubview:shareButton];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp
{
    self.cacheLayer = nil;
    
    self.titleLabel = nil;
    self.likeButton = nil;
    self.shareButton = nil;
    self.titleBox = nil;
    
    self.slideShowView.dataSource = nil;
    self.slideShowView.delegate = nil;
    self.slideShowView = nil;
    
    self.pageControl = nil;
    
    self.textBox.delegate = nil;
    self.textBox = nil;
    
    self.progressView = nil;
    
    self.idModel = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self cleanUp];
}

- (void)dealloc
{
    [self cleanUp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_idModel) {
        [self initIdList];
    } else if (!_dataModel) {
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
    
    UIImageView *imageView = (UIImageView *)[view viewWithTag:kTagSSImageView];
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
    _textBox.text = [_dataModel.descriptions objectAtIndex:(_dataModel.descriptions.count > 1 ? currentIndex : 0)];
}

- (void)slideShowView:(SlideShowView *)slideShowView overSwipWithDirection:(UISwipeGestureRecognizerDirection)direction {
    if (_isAnimating || !_dataModel) {
        return;
    }
    
    BOOL next = direction == UISwipeGestureRecognizerDirectionLeft;
    
    NSInteger idIndex = _idIndex;
    idIndex += (next ? 1 : -1);
    if (idIndex < 0 || idIndex >= _idModel.items.count) {// 到头或尾
        [self performBounce:!next];
        return;
    }
    
    self.idIndex = idIndex;
    
    self.isAnimating = YES;
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    CALayer *cacheLayer = self.cacheLayer = [CALayer layer];
    UIImage *cacheImage = [UIImage imageFromView:self.view];
    cacheLayer.frame = CGRectMake((next ? -1 : 1) * viewWidth, 0, viewWidth, viewHeight);
    cacheLayer.contents = (id)cacheImage.CGImage;
    [self.view.layer insertSublayer:cacheLayer above:self.view.layer];
    
    [self clearContents];
    
    NearItem *currentItem = [_idModel.items objectAtIndex:_idIndex];
    self.offset = [currentItem offset];
    self.contentId = [currentItem contentId];
    self.contentType = [currentItem contentType];
    if ((idIndex == 0 && !next) || (idIndex == _idModel.items.count - 1 && next)) {
        [self requestForNearWorks:next success:^{ // 获取上或下id
            [self requestForSlideShow];
        }];
    } else {
        [self requestForSlideShow];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
//    animation.duration = 5;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake((next ? 1.5f : -0.5f) * viewWidth, viewHeight / 2)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(viewWidth / 2, viewHeight / 2)];
    [self.view.layer addAnimation:animation forKey:@"position"];
}

#pragma mark - FoldableTextBoxDelegate methods

- (void)onFrameChanged:(CGRect)frame {
    frame.origin.y = self.navigationController.navigationBarHidden ? (CompatibleScreenHeight - StatusBarHeight) : (CompatibleContainerHeight - frame.size.height);
    self.textBox.frame = frame;
}

#pragma mark - Private methods

- (void)initIdList {
    if (!_idModel) {
        self.idModel = [[NearWorksModel alloc] init];
        NearItem *item = [[NearItem alloc] init];
        item.contentId = _contentId;
        item.contentType = _contentType;
        item.offset = _offset;
        _idModel.items = [NSMutableArray arrayWithObjects:item, nil];
        
        [self requestForNearWorks:NO success:^{
            [self requestForNearWorks:YES success:^{
                NearItem *currentItem = [_idModel.items objectAtIndex:_idIndex];
                self.offset = [currentItem offset];
                self.contentId = [currentItem contentId];
                self.contentType = [currentItem contentType];
                [self requestForSlideShow];
            }];
        }];
    }
}

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

- (void)share {
    if (!_dataModel) {
        return;
    }
    
    if (!self.shareHelper) {
        self.shareHelper = [[ShareHelper alloc] initWithRootViewController:self];
    }
    
    _shareHelper.title = [_contentType isEqualToString:@"baby"] ? [NSString stringWithFormat:@"牛男宝贝 %@", _dataModel.title]: _dataModel.title;
    _shareHelper.shareUrl = _dataModel.shareUrl;
    [_shareHelper showShareView];
}

- (void)vote {
    SessionManager *sessionManager = [SessionManager sharedManager];
    NSString *babyId = _contentId;
    [sessionManager requsetToken:self success:^(NSString *token) {
        [self requestForVote:babyId withToken:token];
    }];
}

#pragma mark - Private Request methods

- (void)requestForNearWorks:(BOOL)next success:(void (^)())success {
    [self showProgressView];
    
    static NSUInteger count = 1;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_contentType, @"content_type",
                                _contentId, @"content_id",
                                _sortType == SortTypeHotest ? @"hot" : @"new", @"sort_type",
                                _channel, @"channel",
                                [NSNumber numberWithUnsignedInteger:_offset], @"offset",
                                [NSNumber numberWithUnsignedInteger:count], @"count",
                                next ? @"1" : @"-1", @"direction", nil];
    
    [[NNHttpClient sharedClient] getAtPath:@"api/near_work_ids" parameters:parameters responseClass:[NearWorksModel class] success:^(id<Jsonable> response) {
        @synchronized(_idModel) {
            if (!next) {
                self.idIndex = _idIndex + [[((NearWorksModel *)response) items] count];
            }
            [_idModel insertMoreData:response withMode:next];
        }
        
        if (success) {
            success();
        }
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
    }];
}


- (void)requestForSlideShowWithParams:(NSDictionary *)parameters success:(void (^)())success {
    [[NNHttpClient sharedClient] getAtPath:@"api/work_info" parameters:parameters responseClass:[SlideShowDetailModel class] success:^(id<Jsonable> response) {
        self.dataModel = response;
        [self updateData];
        
        if (success) {
            success();
        }
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
    }];
}

- (void)requestForSlideShow {
    [self showProgressView];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:_contentType, @"content_type",
                                _contentId, @"content_id", nil];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    if ([sessionManager getToken] || [sessionManager canAutoLogin]) {
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
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
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
