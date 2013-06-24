//
//  TourSplashViewController.m
//  Neonan
//
//  Created by capricorn on 13-6-24.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "TourViewController.h"

#import <SwipeView.h>
#import <SMPageControl.h>

static const NSUInteger kPageCount = 5;

@interface TourViewController () <SwipeViewDataSource, SwipeViewDelegate>

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet SMPageControl *pageControl;

@end

@implementation TourViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.swipeView.bounces = NO;
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
    
    self.pageControl.numberOfPages = kPageCount;
    self.pageControl.currentPageIndicatorTintColor = HEXCOLOR(0x0096ff);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    [super cleanUp];
    
    self.pageControl = nil;
    
    self.swipeView.dataSource = nil;
    self.swipeView.delegate = nil;
    self.swipeView = nil;
}

#pragma mark - SwipeViewDataSource methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return kPageCount;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, CompatibleContainerHeight)];
        view.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 504)];
        imageView.image = [UIImage imageFromFile:@"img_tour1.png"];
        [view addSubview:imageView];
    }
    
    return view;
}

#pragma mark - SwipeViewDelegate methods

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    self.pageControl.currentPage = swipeView.currentPage;
}

@end
