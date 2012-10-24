//
//  CommentBox.m
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentBox.h"

@interface CommentBox ()
@property (unsafe_unretained, nonatomic) UIImageView * entryImageView;

- (UIButton *)setUpDoneButton;
@end

@implementation CommentBox
@synthesize textView = _textView;
@synthesize rightView = _rightView;

- (void)setUp:(CGRect)frame {
    HPGrowingTextView *textView = self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 4;
    textView.returnKeyType = UIReturnKeyDefault;
    [textView.internalTextView setKeyboardAppearance:UIKeyboardAppearanceAlert];
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"bg_comment_input.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = self.entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"bg_comment_box.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self addSubview:imageView];
    [self addSubview:textView];
    [self addSubview:entryImageView];
    
    UIButton *doneButton = self.doneButton = [self setUpDoneButton];
    [self addSubview:doneButton];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp:frame];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp:self.frame];
}

- (void)dealloc {
    self.textView = nil;
    self.textView.delegate = nil;
    
    self.entryImageView = nil;
    
    self.rightView = nil;
}

- (void)setRightView:(UIView *)view {
    if (_rightView != view) {
        [_rightView removeFromSuperview];
        _rightView = view;
        _doneButton.hidden = view ? YES : NO;
        
        if (view) {
            CGRect frame = view.frame;
            frame.origin.x = self.frame.size.width - view.frame.size.width;
            view.frame = frame;
            NSLog(@"rightView frame:%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            
            [self addSubview:_rightView];
        }
    }
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layoutSubviews");
    
    CGRect frame = self.textView.frame;
    CGFloat textViewWidth = frame.size.width = (_rightView ? _rightView : _doneButton).frame.origin.x - frame.origin.x - /*gap*/5;
    self.textView.frame = frame;
    
    NSLog(@"textView frame:%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    frame = self.entryImageView.frame;
    frame.size.width = textViewWidth + 8;
    self.entryImageView.frame = frame;
}

#pragma mark - HPGrowingTextViewDelegate methods

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.frame = r;
    
    UIView *rightView = _rightView ? _rightView : _doneButton;
    r = rightView.frame;
    r.origin.y -= diff / 2;
    rightView.frame = r;
}

#pragma mark - Private methods

- (UIButton *)setUpDoneButton {
   UIImage *sendBtnBackground = [[UIImage imageNamed:@"bg_comment_commit_normal.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
   UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"bg_comment_commit_highlighted.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        
   UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
   doneBtn.frame = CGRectMake(self.frame.size.width - 69, 8, 63, 27);
   doneBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
   [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
        
   [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
   doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
   doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
   [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   [doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
   [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
   [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
    
    return doneBtn;
}

-(void)resignTextView {
	[self.textView resignFirstResponder];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inside = [super pointInside:point withEvent:event];
    if (!inside) {
        [self resignTextView];
    }
    return inside;
}

@end
