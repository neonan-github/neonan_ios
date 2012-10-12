//
//  GalleryContainerMediator.m
//  Neonan
//
//  Created by capricorn on 12-10-11.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "GalleryContainerMediator.h"
#import "StyledPageControl.h"

@interface GalleryContainerMediator ()
@property (nonatomic, retain) ATPagingView *pagingView;
@property (nonatomic, retain) StyledPageControl *pageControl;
@property (nonatomic, retain) NSArray *images;
@end

@implementation GalleryContainerMediator
@synthesize pagingView = _pagingView, pageControl = _pageControl;
@synthesize images = _images;

- (void)viewDidLoad
{
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
    
    ATPagingView *pagingView = self.pagingView = [[[ATPagingView alloc] initWithFrame:CGRectMake(0, 40, 320, 100)] autorelease];
    pagingView.delegate = self;
    pagingView.horizontal = YES;
    [self addSubview:pagingView];
    
    StyledPageControl *pageControl = self.pageControl = [[[StyledPageControl alloc] initWithFrame:CGRectMake(220, 120, 100, 20)] autorelease];
    [pageControl setPageControlStyle:PageControlStyleDefault]; 
    [self addSubview:pageControl];
    
    self.images = [[[NSArray alloc] initWithObjects:@"home.jpg", @"baby.jpg", @"baby_detail.jpg", @"splash.jpg", nil] autorelease];
}

- (void)dealloc
{
    NSLog(@"==> @(Just for test): GalleryContainerMediator dealloc!!");
    self.pagingView = nil;
    self.pagingView.delegate = nil;
    
    self.pageControl = nil;
    
    [super dealloc];
}

- (void)back
{
    [self popMediatorWithAnimation:From_Left];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"==> @(Just for test): GalleryContainerMediator Appear!!");
    [self.pagingView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"==> @(Just for test): GalleryContainerMediator Disappear!!");
}

#pragma mark － ATPagingViewDelegate methods

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView {
    NSUInteger count = self.images.count;
    [self.pageControl setNumberOfPages:count];
    return count;
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)pagingView atIndex:(NSInteger)index {
    UIImageView *view = (UIImageView *)[pagingView dequeueReusablePage];
    if (view == nil) {
        view = [[[UIImageView alloc] init] autorelease];
        view.clipsToBounds = YES;
        view.contentMode = UIViewContentModeTop;
    }
    
    view.image = [UIImage imageNamed:[self.images objectAtIndex:index]];
    
    return view;
}

- (void)currentPageDidChangeInPagingView:(ATPagingView *)pagingView {
    [self.pageControl setCurrentPage:pagingView.currentPageIndex];
}

@end
