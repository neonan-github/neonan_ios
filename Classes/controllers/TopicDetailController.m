//
//  TopicDetailController.m
//  Neonan
//
//  Created by capricorn on 13-1-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "TopicDetailController.h"

#import <TTTAttributedLabel.h>

static const CGFloat kFixedPartHeight = 300;

@interface TopicDetailController ()

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet TTTAttributedLabel *nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *praiseButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *criticiseButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *contentLabel;
@property (unsafe_unretained, nonatomic) IBOutlet TTTAttributedLabel *rankLabel;

@end

@implementation TopicDetailController

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
    
    self.title = @"TOP 99 女人";
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    _nameLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    [self displayChineseName:@"大S" englishName:@"Barbie Hsu"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setNameLabel:nil];
    [self setPraiseButton:nil];
    [self setCriticiseButton:nil];
    [self setContentLabel:nil];
    [self setRankLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Private UI related

- (void)displayChineseName:(NSString *)chName englishName:(NSString *)enName {
    NSString *text = [NSString stringWithFormat:@"%@ %@", chName, enName];
    [_nameLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange bigRange = [[mutableAttributedString string] rangeOfString:chName options:NSCaseInsensitiveSearch];
        NSRange smallRange = [[mutableAttributedString string] rangeOfString:enName options:NSCaseInsensitiveSearch];
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *bigFont = [UIFont boldSystemFontOfSize:16];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)bigFont.fontName, bigFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:bigRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:bigRange];
            CFRelease(font);
        }
        
        UIFont *smallFont = [UIFont systemFontOfSize:11];
        font = CTFontCreateWithName((__bridge CFStringRef)smallFont.fontName, smallFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:smallRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:smallRange];
            [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:smallRange];
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)RGBA(255, 255, 255, 0.5).CGColor range:smallRange];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
}

@end
