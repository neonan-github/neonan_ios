//
//  VideoPlayController.m
//  Neonan
//
//  Created by capricorn on 12-10-31.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "VideoPlayController.h"
#import "MathHelper.h"

#import <MBProgressHUD.h>

@interface VideoPlayController () <UIWebViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation VideoPlayController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.navigationController.viewControllers.count > 1) {// pushed
        CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
        // Create a custom back button
        UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    } else { //presented
        UIButton *navLeftButton = [UIHelper createBarButton:5];
        [navLeftButton setTitle:@"关闭" forState:UIControlStateNormal];
        [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    }
    
    _webView.delegate = self;
    _webView.hidden = YES;
    
    for (id subview in _webView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_videoUrl]];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.webView.delegate = nil;
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    self.webView.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NNNavigationController *navController = (NNNavigationController *)self.navigationController;
    navController.autoRotate = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];//停止播放
    }
    
    [super viewDidDisappear:animated];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
//    CGFloat contentWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.clientWidth;"] floatValue];
//    CGFloat contentHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.clientHeight;"] floatValue];
//    NSLog(@"width:%f height:%f", contentWidth, contentHeight);
//    CGFloat scale = [MathHelper floorValue:(self.view.frame.size.width / contentWidth) withDecimal:2];
//    CGRect frame = _webView.frame;
//    frame.size.width = scale * contentWidth;
//    frame.size.height = scale * contentHeight;
//    frame.origin.y = (self.view.bounds.size.height - frame.size.height) / 2;
//    webView.frame = frame;
    
//    webView.center = self.view.center;
    webView.hidden = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self performSelector:@selector(autoPlay) withObject:nil afterDelay:1];
}

#pragma mark - Private methods

- (UIButton *)findButtonInView:(UIView *)view {
    UIButton *button = nil;
    
    if ([view isMemberOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findButtonInView:subview];
            if (button) return button;
        }
    }
    
    return button;
}

- (void)autoPlay {
    UIButton *playButton = [self findButtonInView:_webView];
    [playButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    NNNavigationController *navController = (NNNavigationController *)self.navigationController;
    navController.autoRotate = YES;
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

@end
