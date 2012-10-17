//
//  BabyDetailMediator.m
//  Neonan
//
//  Created by capricorn on 12-10-17.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyDetailMediator.h"
#import "StyledPageControl.h"

@interface BabyDetailMediator ()

@property (nonatomic, retain) SlideShowView *slideShowView;
@property (nonatomic, retain) StyledPageControl *pageControl;

@property (nonatomic, retain) NSArray *slideImages;

@end

@implementation BabyDetailMediator
@synthesize slideShowView = _slideShowView, pageControl = _pageControl;
@synthesize slideImages = _slideImages;

- (void)viewDidLoad
{
    float layoutY = 0;
    
    UILabel *navBar = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
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
    
    layoutY += 40;
    SlideShowView *slideShowView = self.slideShowView = [[[SlideShowView alloc] initWithFrame:CGRectMake(0, layoutY, 320, 480 - layoutY)] autorelease];
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    [self addSubview:slideShowView];
    
    StyledPageControl *pageControl = self.pageControl = [[[StyledPageControl alloc] initWithFrame:CGRectMake(0, 440, 320, 20)] autorelease];
    [pageControl setPageControlStyle:PageControlStyleDefault];
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
    
    [super dealloc];
}

- (void)back
{
    [self popMediatorWithAnimation:From_Left];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.slideShowView reloadData];
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


@end
