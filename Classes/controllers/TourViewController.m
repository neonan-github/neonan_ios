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
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@property (nonatomic, strong) IBOutlet UIView *tourView0;
@property (nonatomic, strong) IBOutlet UIView *tourView1;
@property (nonatomic, strong) IBOutlet UIView *tourView2;
@property (nonatomic, strong) IBOutlet UIView *tourView3;
@property (nonatomic, strong) IBOutlet UIView *tourView4;

@property (weak, nonatomic) IBOutlet UIImageView *tour1OverlayView;
@property (weak, nonatomic) IBOutlet UIImageView *tour2OverlayView;
@property (weak, nonatomic) IBOutlet UIImageView *tour3OverlayView;
@property (weak, nonatomic) IBOutlet UIImageView *tour4OverlayView;

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
    
    NSInteger currentPage = self.swipeView.currentPage;
    for (NSInteger i = 0; i < kPageCount && i != currentPage; i++) {
        [self setValue:nil forKey:[NSString stringWithFormat:@"tourView%ld", (long)i]];
    }
}

- (void)cleanUp {
    [super cleanUp];
    
    self.pageControl = nil;
    
    self.swipeView.dataSource = nil;
    self.swipeView.delegate = nil;
    self.swipeView = nil;
    
    self.enterButton = nil;
    
    for (NSInteger i = 0; i < kPageCount; i++) {
        [self setValue:nil forKey:[NSString stringWithFormat:@"tourView%ld", (long)i]];
    }
    
    for (NSInteger i = 1; i < kPageCount; i++) {
        [self setValue:nil forKey:[NSString stringWithFormat:@"tour%ldOverlayView", (long)i]];
    }
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
    if (!swipeView.currentItemView.tag) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"displayPage%ld", (long)swipeView.currentPage]);
        if ([self respondsToSelector:selector]) {
            [self performSelector:selector];
        }
        swipeView.currentItemView.tag = YES;
    }
}

#pragma mark - Private Event Handle

- (void)displayPage1 {
    self.tour1OverlayView.alpha = 0.5;
    self.tour1OverlayView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.8, 0.8), CGAffineTransformMakeTranslation(0, 40));
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.8];
    self.tour1OverlayView.alpha = 1;
    self.tour1OverlayView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, 1), CGAffineTransformMakeTranslation(0, 0));
    [UIView commitAnimations];
}

- (void)displayPage2 {
    self.tour2OverlayView.alpha = 0.5;
    self.tour2OverlayView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.8, 0.8), CGAffineTransformMakeTranslation(0, 0));
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.8];
    self.tour2OverlayView.alpha = 1;
    self.tour2OverlayView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, 1), CGAffineTransformMakeTranslation(0, 0));
    [UIView commitAnimations];
}

- (void)displayPage3 {
    self.tour3OverlayView.alpha = 0.5;
    self.tour3OverlayView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.8, 0.8), CGAffineTransformMakeTranslation(0, 0));
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.8];
    self.tour3OverlayView.alpha = 1;
    self.tour3OverlayView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, 1), CGAffineTransformMakeTranslation(0, 0));
    [UIView commitAnimations];
}

- (void)displayPage4 {
    self.tour4OverlayView.alpha = 0.5;
    self.tour4OverlayView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.8, 0.8), CGAffineTransformMakeTranslation(0, 40));
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.8];
    self.tour4OverlayView.alpha = 1;
    self.tour4OverlayView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, 1), CGAffineTransformMakeTranslation(0, 0));
    [UIView commitAnimations];
}

- (IBAction)enter:(id)sender {
    UIViewController *fromViewController = self;
    UIViewController *toViewController = [(NeonanAppDelegate *)ApplicationDelegate containerController];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
//    [self dismissModalViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [toViewController.view.window addSubview:fromViewController.view];
    fromViewController.view.alpha = 1;
    fromViewController.view.transform = CGAffineTransformMakeScale(1, 1);
    toViewController.view.alpha = 0;
    [UIView animateWithDuration:0.8
                     animations:^{
                         fromViewController.view.alpha = 0;
                         fromViewController.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
                         toViewController.view.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [fromViewController.view removeFromSuperview];
                     }];
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
        self.enterButton.titleLabel.font = [UIFont fontWithName:@"STYuanti-SC-Regular" size:20];
    }
    
    return _tourView4;
}

- (UIView *)tourViewAtPage:(NSUInteger)page {
    return [self valueForKey:[NSString stringWithFormat:@"tourView%lu", (unsigned long)page]];
}

@end
