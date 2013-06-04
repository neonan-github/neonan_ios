//
//  VideoPlayController.m
//  Neonan
//
//  Created by capricorn on 12-10-31.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "VideoPlayViewController.h"

#import "MathHelper.h"
#import "UrlModel.h"
#import "EncourageHelper.h"

#import "UIViewController+JASidePanel.h"

#import <MBProgressHUD.h>
#import <AFNetworking.h>

@interface VideoPlayViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation VideoPlayViewController

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
    if (self.navigationController.viewControllers.count > 1) {// pushed
        UIButton* backButton = [UIHelper createBackButton:self.navigationController.navigationBar];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    } else { //presented
        UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_nav_close.png"];
        [navLeftButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    }
    
    self.view.backgroundColor = DarkThemeColor;
    
    _webView.delegate = self;
    _webView.hidden = YES;
    
    for (id subview in _webView.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;
        }
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self requestUrl:^(NSString * url) {
        self.videoUrl = url;
        DLog(@"videoUrl: %@", url);
        
        Record *record = [[Record alloc] init];
        record.contentType = @"video";
        record.contentId = _contentId;
        [[HistoryRecorder sharedRecorder] saveRecord:record];
        
        __weak VideoPlayViewController *weakSelf = self;
        [EncourageHelper check:_contentId contentType:@"video" afterDelay:5
                        should:^BOOL{
                            return [[SessionManager sharedManager] canAutoLogin] && weakSelf;
                        }
                       success:nil];
        
        [self parseVideoUrl:url done:^(NSString *newUrl) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:newUrl]
                                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                 timeoutInterval:20];
            [_webView loadRequest:request];
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateDidChange:)
                                                 name:@"MPAVControllerPlaybackStateChangedNotification"
                                               object:nil];
}

- (void)cleanUp {
    self.webView.delegate = nil;
    self.webView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NNContainerViewController *containerController = (NNContainerViewController *)self.sidePanelController.centerPanel;
    containerController.autoRotate = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIViewController attemptRotationToDeviceOrientation];
    
    [super viewWillDisappear:animated];
    
    NNContainerViewController *containerController = (NNContainerViewController *)self.sidePanelController.centerPanel;
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
    } else {
        containerController.autoRotate = YES;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];//停止播放
    }
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    DLog(@"webViewDidFinishLoad");
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

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Private Request Related

- (void)requestUrl:(void (^)(NSString *))completion {
    if (_videoUrl) {
        if (completion) {
            completion(_videoUrl);
        }
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_contentId, @"content_id",
                                    @"video", @"content_type", nil];
        
        [[NNHttpClient sharedClient] getAtPath:kPathWorkInfo
                                    parameters:parameters
                                 responseClass:[UrlModel class]
                                       success:^(id<Jsonable> response) {
                                           if (completion) {
                                               completion(((UrlModel *)response).url);
                                           }
                                       } failure:^(ResponseError *error) {
                                           if (self.isVisible) {
                                               [UIHelper alertWithMessage:error.message];
                                           }
                                       }];
    }
}

- (void)parseVideoUrl:(NSString *)url done:(void (^)(NSString *newUrl))done {
    if (!done) {
        return;
    }
    
    static NSString *qqPrefix = @"http://static.video.qq.com/TPout.swf?vid=";
    if ([url rangeOfString:qqPrefix].location != NSNotFound) {
        [self parseQQVideoUrl:url done:^(NSString *newUrl) {
            done(newUrl);
        }];
        
        return;
    }
    
    static NSString *tudou1 = @"http://www.tudou.com/v/";
    static NSString *tudou1_1 = @"http://www.tudou.com/programs/view/";
    static NSString *tudou2 = @"http://www.tudou.com/programs/view/html5embed.action?code=";
    static NSString *youku1 = @"http://player.youku.com/player.php/sid/";
    static NSString *youku1_1 = @"http://v.youku.com/v_show/id_";
    static NSString *youku2 = @"http://player.youku.com/embed/";
    
    
    if (url == nil || url.length == 0) {
        
    } else if ([url rangeOfString:tudou1].location == 0) {
        int location = [url rangeOfString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(tudou1.length, url.length - tudou1.length)].location;
        if (location < url.length && location > tudou1.length) {
            done([NSString stringWithFormat:@"%@%@", tudou2, [url substringWithRange:NSMakeRange(tudou1.length, location - tudou1.length)]]);
        }
    } else if ([url rangeOfString:tudou1_1].location == 0) {
        int location = [url rangeOfString:@"?" options:NSCaseInsensitiveSearch range:NSMakeRange(tudou1_1.length, url.length - tudou1_1.length)].location;
        if (location < url.length && location > tudou1_1.length) {
            done([NSString stringWithFormat:@"%@%@", tudou2, [url substringWithRange:NSMakeRange(tudou1_1.length, location - tudou1_1.length)]]);
        }
    } else if ([url rangeOfString:youku1].location == 0) {
        int location = [url rangeOfString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(youku1.length, url.length - youku1.length)].location;
        if (location < url.length && location > youku1.length) {
            done([NSString stringWithFormat:@"%@%@", youku2, [url substringWithRange:NSMakeRange(youku1.length, location - youku1.length)]]);
        }
    } else if ([url rangeOfString:youku1_1].location == 0) {
        int location = [url rangeOfString:@"." options:NSCaseInsensitiveSearch range:NSMakeRange(youku1_1.length, url.length - youku1_1.length)].location;
        if (location < url.length && location > youku1_1.length) {
            done([NSString stringWithFormat:@"%@%@", youku2, [url substringWithRange:NSMakeRange(youku1_1.length, location - youku1_1.length)]]);
        }
    }
}

- (void)parseQQVideoUrl:(NSString *)url done:(void (^)(NSString *newUrl))done {
    static NSString *prefix = @"http://static.video.qq.com/TPout.swf?vid=";
    
    NSRange range = [url rangeOfString:prefix];
    if (range.location != NSNotFound) {
        NSString *vid = [url substringWithRange:NSMakeRange(range.length, 11)];
        DLog(@"vid: %@", vid);
        
        AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://vv.video.qq.com"]];
        [httpClient getPath:@"geturl"
                 parameters:@{@"otype": @"json", @"vid": vid}
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSString *response = [operation responseString];
                        NSRange range = [response rangeOfString:[NSString stringWithFormat:@"%@.mp4", vid]];
                        if (range.location != NSNotFound) {
                            NSRange prefixQuotationRange = [response rangeOfString:@"\""
                                                                           options:NSBackwardsSearch
                                                                             range:NSMakeRange(0, range.location)];
                            NSRange brRange = [response rangeOfString:@"&br"
                                                                           options:NSCaseInsensitiveSearch
                                                                             range:NSMakeRange(range.location, response.length - range.location)];
                            done([response substringWithRange:NSMakeRange(prefixQuotationRange.location + 1,
                                                                          brRange.location - 1 - prefixQuotationRange.location)]);
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        if (self.isVisible) {
                            [UIHelper alertWithMessage:@"网络连接失败"];
                        }
                    }];
    }
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

- (void)playbackStateDidChange:(NSNotification *)note {
    NNContainerViewController *containerController = (NNContainerViewController *)self.sidePanelController.centerPanel;
    
    NSInteger state = [[note.userInfo objectForKey:@"MPAVControllerNewStateParameter"] integerValue];
    if (state == 1) { // stop
        containerController.autoRotate = NO;
    } else if (state == 2) { // start
        containerController.autoRotate = YES;
    }
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

@end
