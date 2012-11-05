//
//  VideoPlayController.m
//  Neonan
//
//  Created by capricorn on 12-10-31.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "VideoPlayController.h"
#import "MathHelper.h"

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
    UIButton *navLeftButton = [UIHelper createBarButton:5];
    [navLeftButton setTitle:@"关闭" forState:UIControlStateNormal];
    [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    _webView.delegate = self;
    _webView.hidden = YES;
    
    NSString *embedHTML = @"\
	<html><head>\
	<meta name=\"apple-touch-fullscreen\" content=\"YES\" /><meta name=\"apple-mobile-web-app-capable\" content=\"yes\" /><meta name=\"viewport\" content=\"width=device-width,initial-scale=%.2f,minimum-scale=%.2f,maximum-scale=%.2f,user-scalable=no\" /></head>\
	<body style=\"background:#000;margin:0px;\">\
	<iframe width=510 height=498 src=\"http://player.youku.com/embed/XNDcwNjA1MjQ0\" frameborder=0 ></iframe>\
	</body></html>";
    
    CGFloat scale = [MathHelper floorValue:(self.view.frame.size.width / 510) withDecimal:2];
    
    CGRect frame = _webView.frame;
    frame.size.width = scale * 510;
    frame.size.height = scale * 498;
    _webView.frame = frame;
    
    _webView.center = self.view.center;
    
    for (id subview in _webView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    
    NSString *html = [NSString stringWithFormat:embedHTML, scale, scale, scale];
    NSLog(embedHTML, scale, scale, scale);
    [_webView loadHTMLString:html baseURL:nil];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];//停止播放
    
    [super viewDidDisappear:animated];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
    webView.hidden = NO;
    
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
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

@end
