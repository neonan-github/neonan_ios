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

@property (nonatomic, strong) IBOutlet UIView *tourView0;
@property (nonatomic, strong) IBOutlet UIView *tourView1;
@property (nonatomic, strong) IBOutlet UIView *tourView2;
@property (nonatomic, strong) IBOutlet UIView *tourView3;
@property (nonatomic, strong) IBOutlet UIView *tourView4;

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
    return [self tourViewAtPage:index];
}

#pragma mark - SwipeViewDelegate methods

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    self.pageControl.currentPage = swipeView.currentPage;
}

#pragma mark - Private Event Handle

- (IBAction)enter:(id)sender {
}

#pragma mark - Private methods

- (UIView *)tourView0 {
    if (!_tourView0) {
        [[NSBundle mainBundle] loadNibNamed:IS_IPHONE_5 ? @"tour0-iphone5" : @"tour0" owner:self options:nil];
    }
    
    return _tourView0;
}

- (UIView *)tourView1 {
    if (!_tourView1) {
        [[NSBundle mainBundle] loadNibNamed:@"tour1" owner:self options:nil];
    }
    
    return _tourView1;
}

- (UIView *)tourView2 {
    if (!_tourView2) {
        [[NSBundle mainBundle] loadNibNamed:@"tour2" owner:self options:nil];
    }
    
    return _tourView2;
}

- (UIView *)tourView3 {
    if (!_tourView3) {
        [[NSBundle mainBundle] loadNibNamed:@"tour3" owner:self options:nil];
    }
    
    return _tourView3;
}

- (UIView *)tourView4 {
    if (!_tourView4) {
        [[NSBundle mainBundle] loadNibNamed:IS_IPHONE_5 ? @"tour4-iphone5" : @"tour4" owner:self options:nil];
    }
    
    return _tourView4;
}

- (UIView *)tourViewAtPage:(NSUInteger)page {
    return [self valueForKey:[NSString stringWithFormat:@"tourView%d", page]];
}

@end
