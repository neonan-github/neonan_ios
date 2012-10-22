//
//  BabyDetailMediator.m
//  Neonan
//
//  Created by capricorn on 12-10-17.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyDetailMediator.h"
#import "StyledPageControl.h"
#import "NSString+TruncateToWidth.h"
#import "UILabel+dynamicSizeMe.h"
#import <HPGrowingTextView.h>
#import "UnselectableTextView.h"

static const float kDescriptionShrinkedLines = 4;
static const float kDescriptionStretchedLines = 7;

@interface BabyDetailMediator ()
@property (nonatomic, retain) UILabel *navigationBar;
@property (nonatomic, retain) SlideShowView *slideShowView;
@property (nonatomic, retain) StyledPageControl *pageControl;
@property (nonatomic, retain) UILabel *descriptionLabel;
@property (nonatomic, retain) UIScrollView *descriptionContainer;
@property (nonatomic, retain) UnselectableTextView *descriptionView;

@property (nonatomic, retain) NSArray *slideImages;

@end

@implementation BabyDetailMediator
@synthesize navigationBar = _navigationBar;
@synthesize slideShowView = _slideShowView, pageControl = _pageControl;
@synthesize slideImages = _slideImages;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize descriptionView = _descriptionView;
@synthesize description = _description;

- (void)viewDidLoad
{
    self.description = @"杨棋涵毕业于中国音乐学院，有“小范冰冰”之称。以性感、冷艳、奢华、高贵等多种造型成为2010年娱乐媒体关注的焦点，更是频频亮相《男人装》、《瑞丽》、《时尚芭莎》等时尚杂志。";
    
    SlideShowView *slideShowView = self.slideShowView = [[[SlideShowView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)] autorelease];
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
    [slideShowView addGestureRecognizer:tapRecognizer];
    [self addSubview:slideShowView];
    
    UILabel *navBar = self.navigationBar = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
    navBar.text = @"自定义导航栏";
    navBar.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    navBar.textAlignment = NSTextAlignmentCenter;
    navBar.userInteractionEnabled = YES;
    [self addSubview:navBar];
    
    UIButton *back = [[[UIButton alloc] initWithFrame:CGRectMake(10, 5, 60, 30)] autorelease];
    back.layer.cornerRadius = 10;
    [back setBackgroundColor:[UIColor grayColor]];
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:back];
    
    UnselectableTextView *descriptionView = self.descriptionView = [[[UnselectableTextView alloc] initWithFrame:CGRectMake(0, 400, 320, 0)] autorelease];
    descriptionView.backgroundColor = [UIColor lightGrayColor];
    descriptionView.editable = NO;
//    descriptionView.scrollEnabled = NO;
    self.description = @"杨棋涵毕业于中国音乐学院，有“小范冰冰”之称。以性感、冷艳、奢华、高贵等多种造型成为2010年娱乐媒体关注的焦点，更是频频亮相《男人装》、《瑞丽》、《时尚芭莎》等时尚杂志。杨棋涵毕业于中国音乐学院，有“小范冰冰”之称。以性感、冷艳、奢华、高贵等多种造型成为2010年娱乐媒体关注的焦点，更是频频亮相《男人装》、《瑞丽》、《时尚芭莎》等时尚杂志";
    descriptionView.text = [self.description stringByTruncatingToWidth:(self.descriptionView.contentSize.width - 16) * kDescriptionShrinkedLines withFont:descriptionView.font andEllipsis:@"…  "];
//    [UIHelper fitScrollView:descriptionView withMaxHeight:kDescriptionStretchedLines * self.descriptionView.font.lineHeight];
//    [UIHelper view:descriptionView alignBottomTo:460];
    tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
    [descriptionView addGestureRecognizer:tapRecognizer];
    [self addSubview:descriptionView];
    
    StyledPageControl *pageControl = self.pageControl = [[[StyledPageControl alloc] initWithFrame:CGRectMake(0, 435, 320, 20)] autorelease];
    [pageControl setPageControlStyle:PageControlStyleDefault];
    pageControl.userInteractionEnabled = NO;
    pageControl.coreNormalColor = [UIColor whiteColor];
    pageControl.coreSelectedColor = [UIColor blueColor];
    [self addSubview:pageControl];

    self.slideImages = [[[NSArray alloc] initWithObjects:@"home.jpg", @"baby.jpg", @"baby_detail.jpg", @"splash.jpg", @"article_detail.jpg", @"article_list.jpg", nil] autorelease];
}

- (void)dealloc
{
    self.slideShowView.dataSource = nil;
    self.slideShowView.delegate = nil;
    self.slideShowView = nil;

    self.pageControl = nil;
    self.slideImages = nil;
    
    self.navigationBar = nil;
    self.descriptionLabel = nil;
    self.descriptionContainer = nil;
    self.descriptionView = nil;
    
    self.description = nil;
    
    [super dealloc];
}

- (void)back
{
    [self popMediatorWithAnimation:From_Left];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.slideShowView reloadData];
    [UIHelper fitScrollView:self.descriptionView withMaxHeight:kDescriptionStretchedLines * self.descriptionView.font.lineHeight];
    [UIHelper view:self.descriptionView alignBottomTo:460];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"==> @(Just for test): TestMediator Disappear!!");
}

#pragma mark - SlideShowViewDataSource methods

- (NSUInteger)numberOfItemsInSlideShowView:(SlideShowView *)slideShowView {
    NSUInteger count = self.slideImages.count;
    [self.pageControl setNumberOfPages:count];
    return count;
    
}

- (UIView *)slideShowView:(SlideShowView *)slideShowView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[[UIImageView alloc] init] autorelease];
        view.clipsToBounds = YES;
        view.contentMode = UIViewContentModeTop;
    }
    
    ((UIImageView *)view).image = [UIImage imageNamed:[self.slideImages objectAtIndex:index]];
    
    return view;
}

#pragma mark - SlideShowViewDelegate methods

- (void)slideShowViewItemIndexDidChange:(SlideShowView *)slideShowView {
    [self.pageControl setCurrentPage:slideShowView.carousel.currentItemIndex];
}

#pragma mark - Private methods

- (void)tap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"touched view:%@", recognizer.view);
    
    if (recognizer.view == self.descriptionView) {
        BOOL shrinked = !self.descriptionView.scrollEnabled;
        self.descriptionView.text = self.descriptionView.scrollEnabled ? [self.description stringByTruncatingToWidth:(self.descriptionView.contentSize.width - 16) * kDescriptionShrinkedLines withFont:self.descriptionView.font andEllipsis:@"…  "] : self.description;
        [self.descriptionView scrollsToTop];
        self.descriptionView.scrollEnabled = shrinked;
        [UIHelper fitScrollView:self.descriptionView withMaxHeight:kDescriptionStretchedLines * self.descriptionView.font.lineHeight];
        [UIHelper view:self.descriptionView alignBottomTo:460];
    } else {
        BOOL hidden = self.navigationBar.frame.origin.y >= 0;
        float navigationBarDeltaY = -self.navigationBar.frame.size.height * (hidden ? 1 : 0);
        float descriptionViewDeltaY = self.descriptionView.frame.size.height * (hidden ? 1 : 0);
        [UIView animateWithDuration:0.3 delay:0
                            options:(hidden ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             self.navigationBar.transform = CGAffineTransformMakeTranslation(0, navigationBarDeltaY);
                             self.descriptionView.transform = CGAffineTransformMakeTranslation(0, descriptionViewDeltaY);
                         } completion:nil];
    }
}

@end


