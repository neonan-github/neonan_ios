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
#import "ShareHelper.h"

static const float kDescriptionShrinkedLines = 4;
static const float kDescriptionStretchedLines = 7;

@interface BabyDetailController () <SlideShowViewDataSource, SlideShowViewDelegate,
FoldableTextBoxDelegate>

@property (nonatomic, unsafe_unretained) UIView *titleBox;
@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UIButton *likeButton;
@property (nonatomic, unsafe_unretained) UIButton *shareButton;

@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) FoldableTextBox *textBox;

@property (nonatomic, strong) SlideShowDetailModel *dataModel;
@property (strong, nonatomic) ShareHelper *shareHelper;

- (void)requestForSlideShow;

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
    
    UILabel *titleLabel = self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 240, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:13];
    
    UIButton *likeButton = self.likeButton = [[UIButton alloc] initWithFrame:CGRectMake(261, 12, 16, 15)];
    [likeButton setBackgroundImage:[UIImage imageFromFile:@"icon_love_normal.png"] forState:UIControlStateNormal];
    [likeButton setBackgroundImage:[UIImage imageFromFile:@"icon_love_highlighted.png"] forState:UIControlStateHighlighted];
    
    UIButton *shareButton = self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(290, 12, 20, 15)];
    [shareButton setBackgroundImage:[UIImage imageFromFile:@"icon_share.png"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *titleBox = self.titleBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 35)];
    titleBox.backgroundColor = DarkThemeColor;
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
    
    if (_dataModel) {
        [self.slideShowView reloadData];
    } else {
        [self requestForSlideShow];
    }
    _textBox.expanded = NO;
}

#pragma mark - SlideShowViewDataSource methods

- (NSUInteger)numberOfItemsInSlideShowView:(SlideShowView *)slideShowView {
    NSUInteger count = _dataModel.imgUrls.count;
    [self.pageControl setNumberOfPages:count];
    return count;
    
}

- (UIView *)slideShowView:(SlideShowView *)slideShowView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIImageView alloc] init];
        view.clipsToBounds = YES;
        view.contentMode = UIViewContentModeScaleAspectFit;
        
        UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        progressView.tag = 1000;
        
        CGRect frame = progressView.frame;
        frame.origin.x = (slideShowView.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = (slideShowView.bounds.size.height - frame.size.height) / 2;
        progressView.frame = frame;
        [view addSubview:progressView];
    }
    
    UIActivityIndicatorView *progressView = (UIActivityIndicatorView *)[view viewWithTag:1000];
    NSURL *imgUrl = [NSURL URLWithString:[_dataModel.imgUrls objectAtIndex:index]];
    [((UIImageView *)view) setImageWithURL:imgUrl success:^(UIImage *image, BOOL cached) {
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
    [self.pageControl setCurrentPage:currentIndex];
    _textBox.text = [_dataModel.descriptions objectAtIndex:(_dataModel.descriptions.count > 1 ? currentIndex : 0)];
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

#pragma mark - Private Request methods

- (void)requestForSlideShow {
    UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect frame = progressView.frame;
    frame.origin.x = (_slideShowView.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = (_slideShowView.bounds.size.height - frame.size.height) / 2;
    progressView.frame = frame;
    [_slideShowView addSubview:progressView];
    [progressView startAnimating];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_contentType, @"content_type",
                                _contentId, @"content_id", nil];
    
    [[NNHttpClient sharedClient] getAtPath:@"work_info" parameters:parameters responseClass:[SlideShowDetailModel class] success:^(id<Jsonable> response) {
        self.dataModel = response;
        [self updateData];
        [progressView removeFromSuperview];
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
    }];
}

#pragma mark - Private UI related

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

- (void)updateData {
    [_slideShowView reloadData];
    [self slideShowViewItemIndexDidChange:_slideShowView];
    
    _titleLabel.text = _dataModel.title;
}

@end
