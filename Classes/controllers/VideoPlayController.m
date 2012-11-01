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
//    
//    NSString *embedHTML = @"\
//	<html><head>\
//	<meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 620\"/></head>\
//	<script>document.ontouchmove = function(event) {event.preventDefault();}</script>\
//	<body style=\"background:#000;margin:0px;\">\
//	<div><iframe width=\"620\" height=\"348\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
//	</div></body></html>";
//    
//    NSString *html = [NSString stringWithFormat:embedHTML, @"http://player.youku.com/embed/XNDY4OTU1Mzky"];
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://player.youku.com/embed/XNDY5MjU5NTg4"]]];
//    NSString *html = [NSString stringWithFormat:@"<iframe frameborder=0 src=\"http://player.youku.com/embed/XNDY4OTU1Mzky\"></iframe>"];
//    [_webView loadHTMLString:html baseURL:nil];
//    [_webView loadHTMLString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><meta name=\"viewport\" content=\"width=320; initial-scale=1.0; minimum-scale=1.0;\"/><title>Untitled Document</title></head><body><iframe height=498 width=510 frameborder=0 src=\"http://player.youku.com/embed/XNDY4OTU1Mzky\" frameborder=0 allowfullscreen></iframe></body></html>" baseURL:nil];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://player.youku.com/embed/XNDY4OTU1Mzky"]]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];//停止播放
    
    [super viewDidDisappear:animated];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    CGRect frame = webView.frame;
//    frame.size.height = 1;
//    webView.frame = frame;
//    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
//    frame.size = fittingSize;
//    webView.frame = frame;
    
//    if ([webView respondsToSelector:@selector(scrollView)])
//    {
//        UIScrollView *scroll=[webView scrollView];
//        
//        float zoom=webView.bounds.size.width/scroll.contentSize.width;
//        float zoom2 = webView.bounds.size.height/scroll.contentSize.height;
//        scroll.minimumZoomScale = MIN(zoom, zoom2);
//        scroll.maximumZoomScale = MIN(zoom, zoom2);
//        scroll.zoomScale = MIN(zoom, zoom2);
//    }
    
//    NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
//    CGFloat contentHeight = [[webView stringByEvaluatingJavaScriptFromString:
//                              @"document.documentElement.scrollHeight"] floatValue];
//	webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y,
//                               webView.frame.size.width, contentHeight);
}

@end
