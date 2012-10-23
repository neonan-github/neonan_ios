//
//  ArticleDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ArticleDetailController.h"
#import "CommentBox.h"
#import <DTCoreText.h>

@interface ArticleDetailController ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet DTAttributedTextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet CommentBox *commentBox;

@property (strong, nonatomic) UIView *commentBoxRightView; //分享及评论

- (UIView *)setUpCommentBoxRightView;

@end

@implementation ArticleDetailController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setTextView:nil];
    [self setCommentBox:nil];
    self.commentBoxRightView = nil;
    [super viewDidUnload];
}

#pragma mark - Private methods

- (UIView *)setUpCommentBoxRightView {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 98, 40)];
}

@end
