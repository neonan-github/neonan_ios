//
//  ShareEditController.m
//  Neonan
//
//  Created by capricorn on 12-11-6.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ShareEditController.h"
#import "LoadingView.h"

const NSUInteger kMaxInputLimit = 140;

@interface ShareEditController () <UITextViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *bindInfoLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *inputLimitLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *textBgView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) LoadingView *loadingView;
@property (unsafe_unretained, nonatomic) UIButton *shareButton;

- (void)loadingViewDidDismissed;
- (void)loadingViewDelayClose;

- (void)updateLimitHit;
@end

@implementation ShareEditController

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
    self.view.backgroundColor = DarkThemeColor;
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *navRightButton = self.shareButton = [UIHelper createBarButton:5];
    [navRightButton setTitle:@"分享" forState:UIControlStateNormal];
    [navRightButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    _bindInfoLabel.text = [_shareItem isVerified] ? @"已绑定" : @"未绑定";
    
    UIImage* textBgImage = [[UIImage imageFromFile:@"bg_share_edit.png"] stretchableImageWithLeftCapWidth:27 topCapHeight:27];
    [_textBgView setImage:textBgImage];
    
    _textView.delegate = self;
    _textView.text = [NSString stringWithFormat:@" // %@", [_shareItem sharedText]];
    _textView.selectedRange = NSMakeRange(0, 0);
    
    [self updateLimitHit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBindInfoLabel:nil];
    [self setInputLimitLabel:nil];
    [self setTextView:nil];
    self.loadingView = nil;
    self.shareButton = nil;
    [self setTextBgView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect frame = _textView.frame;
    frame.size.height = self.view.frame.size.height - frame.origin.y - KeyboardPortraitHeight - 10;
    _textView.frame = frame;
    
    frame = _textBgView.frame;
    frame.size.height = _textView.frame.size.height;
    _textBgView.frame = frame;
    
    [_textView becomeFirstResponder];
}

#pragma mark - SHSOAuthShareDelegate

- (void)OAuthSharerDidBeginVerification:(id<SHSOAuthSharerProtocol>)oauthSharer
{
    if(!_loadingView)
        _loadingView=[[LoadingView alloc] initWithFrame:CGRectMake(0, 0, 130, 100) LoadingViewStyle:LoadingViewStyleStandard];
    _loadingView.titleLabel.font=[UIFont boldSystemFontOfSize:13];
    _loadingView.title=@"加载中";
    
    _loadingView.alpha=0;
    _loadingView.transform=CGAffineTransformMakeScale(1.7f, 1.7f);
    [_loadingView showInView:self.view];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    _loadingView.alpha=1;
    _loadingView.transform=CGAffineTransformMakeScale(1, 1);
    [UIView commitAnimations];
}

- (void)OAuthSharerDidFinishVerification:(id<SHSOAuthSharerProtocol>)oauthSharer
{
    [self loadingViewDidDismissed];
}

- (void)OAuthSharerDidCancelVerification:(id<SHSOAuthSharerProtocol>)oauthSharer
{
    [self loadingViewDidDismissed];
}

- (void)OAuthSharerDidFailInVerification:(id<SHSOAuthSharerProtocol>)oauthSharer
{
    [self loadingViewDidDismissed];
    
    if(!_loadingView)
        _loadingView=[[LoadingView alloc] initWithFrame:CGRectMake(0, 0, 130, 100) LoadingViewStyle:LoadingViewStyleTilte];
    _loadingView.titleLabel.font=[UIFont boldSystemFontOfSize:15];
    _loadingView.title=@"用户授权失败";
    
    _loadingView.alpha=0;
    _loadingView.transform=CGAffineTransformMakeScale(1.7f, 1.7f);
    [_loadingView showInView:self.view];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    _loadingView.alpha=1;
    _loadingView.transform=CGAffineTransformMakeScale(1, 1);
    [UIView commitAnimations];
    [self performSelector:@selector(loadingViewDelayClose) withObject:nil afterDelay:1];
}

- (void)OAuthSharerDidBeginShare:(id<SHSOAuthSharerProtocol>)oauthSharer
{
    if(!_loadingView)
        _loadingView=[[LoadingView alloc] initWithFrame:CGRectMake(0, 0, 130, 100) LoadingViewStyle:LoadingViewStyleTilte];
    _loadingView.titleLabel.font=[UIFont boldSystemFontOfSize:15];
    _loadingView.title=@"分享中";
    
    _loadingView.alpha=0;
    _loadingView.transform=CGAffineTransformMakeScale(1.7f, 1.7f);
    [_loadingView showInView:self.view];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    _loadingView.alpha=1;
    _loadingView.transform=CGAffineTransformMakeScale(1, 1);
    [UIView commitAnimations];
}

- (void)OAuthSharerDidFinishShare:(id<SHSOAuthSharerProtocol>)oauthSharer
{
    _loadingView.title=@"分享成功!";
    [self performSelector:@selector(loadingViewDelayClose) withObject:nil afterDelay:1];
}

- (void)OAuthSharerDidFailShare:(id<SHSOAuthSharerProtocol>)oauthSharer
{
    _loadingView.title=@"分享失败!";
    [self performSelector:@selector(loadingViewDelayClose) withObject:nil afterDelay:1];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateLimitHit];
}

#pragma mark - Public methods

-(NSString *)getTrackUrl:(NSString *)source trackCB:(BOOL)trackCB site:(NSString *)site
{
    NSString *pattern = @"http://www.bshare.cn/burl?url=%@&publisherUuid=%@&site=%@";
    NSString *uuid = PUBLISHER_UUID;
    if (!uuid) {
        uuid = @"";
    }
    if (!site){
        site = @"";
    }
    if (source && trackCB) {
        return [NSString stringWithFormat:pattern,source,uuid,site];
    }
    return [NSString stringWithString:source];
}

#pragma mark - Private methods

- (void)loadingViewDelayClose
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(loadViewDidDismissed)];
    _loadingView.alpha=0;
    _loadingView.transform=CGAffineTransformMakeScale(1.7f, 1.7f);
    [UIView commitAnimations];
}

- (void)loadingViewDidDismissed
{
    [_loadingView dismiss];
    self.loadingView = nil;
}

- (void)updateLimitHit {
    NSInteger lengthRemain = kMaxInputLimit - _textView.text.length;
    if (lengthRemain < 0) {
        _inputLimitLabel.text = [NSString stringWithFormat:@"已超%d个字", -lengthRemain];
        _inputLimitLabel.textColor = [UIColor redColor];
        self.shareButton.enabled = NO;
        return;
    }
    
    _inputLimitLabel.text = [NSString stringWithFormat:@"还可输入%d个字", lengthRemain];
    _inputLimitLabel.textColor = [UIColor whiteColor];
    self.shareButton.enabled = YES;
}

- (void)share {
    NSString *text = _textView.text;
    if(!text || [text isEqualToString:@""]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"必须指定要分享的内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if([_shareItem conformsToProtocol:@protocol(SHSOAuthSharerProtocol)])  {
        [((id<SHSOAuthSharerProtocol>)_shareItem) shareText:_textView.text];
    }
}

@end
