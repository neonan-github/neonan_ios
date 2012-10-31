//
//  VideoPlayController.m
//  Neonan
//
//  Created by capricorn on 12-10-31.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "VideoPlayController.h"

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
    self.webView.delegate = self;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *html = [NSString stringWithFormat:@"<iframe height=%0.0f width=%0.0f frameborder=0 src=\"http://player.youku.com/embed/XNDY4OTU1Mzky\" frameborder=0 allowfullscreen></iframe>", self.view.frame.size.height, self.view.frame.size.width];
    [_webView loadHTMLString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=no;\"/><title>Untitled Document</title></head><body><iframe height=498 width=510 frameborder=0 src=\"http://player.youku.com/embed/XNDY4OTU1Mzky\" frameborder=0 allowfullscreen></iframe></body></html>" baseURL:nil];
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"<iframe height=498 width=510 frameborder=0 src=\"http://player.youku.com/embed/XNDY4OTU1Mzky\" frameborder=0 allowfullscreen></iframe>"]]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];//停止播放
    
    [super viewDidDisappear:animated];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    NSString *jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = 0.1;"];
    [webView stringByEvaluatingJavaScriptFromString:jsCommand];
    
    NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
}

@end
