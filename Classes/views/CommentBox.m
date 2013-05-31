//
//  CommentBox.m
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentBox.h"

@interface CommentBox () {
    NSString *_text;
}

@property (unsafe_unretained, nonatomic) UIImageView *entryImageView;
@property (assign, nonatomic, getter = isActive) BOOL active;

@end

@implementation CommentBox
@synthesize textView = _textView;
@synthesize rightView = _rightView;

- (void)setUp:(CGRect)frame {
    HPGrowingTextView *textView = self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(50, 7, 208, 30)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 0);
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 4;
    textView.returnKeyType = UIReturnKeyDefault;
    [textView.internalTextView setKeyboardAppearance:UIKeyboardAppearanceAlert];
    textView.font = [UIFont systemFontOfSize:12];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor clearColor];
    
    UIImageView *placeHolderView = self.placeHolderView = [[UIImageView alloc] initWithFrame:CGRectMake(5, (textView.frame.size.height - 16) / 2 , 56, 16)];
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"img_comment_placeholder" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    placeHolderView.image = [UIImage imageWithData:imageData];
    [textView addSubview:placeHolderView];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"bg_comment_input"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:21 topCapHeight:15];
    UIImageView *entryImageView = self.entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(50, 7, 208, 30);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageFromFile:@"bg_comment_box.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:10 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self addSubview:imageView];
    [self addSubview:entryImageView];
    [self addSubview:textView];
    
    UIButton *doneButton = self.doneButton = [self setUpDoneButton];
    doneButton.enabled = NO;
    [self addSubview:doneButton];
    
    UIButton *countButton = self.countButton = [[UIButton alloc] initWithFrame:CGRectMake(4, (frame.size.height - 40) / 2, 40, 40)];
    [countButton setBackgroundImage:[UIImage imageFromFile:@"bg_comment_count.png"] forState:UIControlStateNormal];
    countButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 4, 0);
    countButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    countButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [countButton setTitleShadowColor:RGBA(0, 0, 0, 0.75) forState:UIControlStateNormal];
    [countButton setTitleColor:HEXCOLOR(0x555555) forState:UIControlStateNormal];
    [self addSubview:countButton];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
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
    
    [self removeObserver:self forKeyPath:@"frame"];
}

- (NSString *)text {
    return [_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setText:(NSString *)text {
    _text = [text copy];
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
            DLog(@"rightView frame:%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
            [self addSubview:_rightView];
        }
        
        CGRect frame = self.textView.frame;
        CGFloat textViewWidth = (_rightView ? _rightView : _doneButton).frame.origin.x - frame.origin.x;
        frame.size.width = textViewWidth;
        self.textView.frame = frame;
    }
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.textView.frame;
    CGFloat textViewWidth = (_rightView ? _rightView : _doneButton).frame.origin.x - frame.origin.x;
    frame.size.width = textViewWidth;
    self.textView.frame = frame;
    
    frame = self.entryImageView.frame;
    frame.size.width = textViewWidth;
    self.entryImageView.frame = frame;
    
    [self alignParentCenter:self.entryImageView];
    [self alignParentCenter:_countButton];
    [self alignParentCenter:_rightView];
    [self alignParentCenter:_doneButton];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inside = [super pointInside:point withEvent:event];
    if (!inside) {
        [self resignTextView];
    }
    
    DLog(@"isActive:%@", self.isActive ? @"YES" : @"NO");
    return self.isActive ? YES : inside;
}

#pragma mark - HPGrowingTextViewDelegate methods

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
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
    UIButton* doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(self.width - 64, 0, 64, self.height);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [doneBtn setTitleColor:HEXCOLOR(0x0096ff) forState:UIControlStateHighlighted];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [doneBtn setTitle:@"发表" forState:UIControlStateNormal];
    
    [doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
//   [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
//   [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
    
    return doneBtn;
}

- (void)resignTextView {
	[self.textView resignFirstResponder];
}

- (void)alignParentCenter:(UIView *)view {
    CGRect frame = view.frame;
    CGPoint center = view.center;
    center.x = frame.origin.x + frame.size.width / 2;
    center.y = self.frame.size.height / 2;
    view.center = center;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"frame"]) {
        CGRect oldFrame = CGRectNull;
        CGRect newFrame = CGRectNull;
        if([change objectForKey:@"old"] != [NSNull null]) {
            oldFrame = [[change objectForKey:@"old"] CGRectValue];
        }
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
        }
        
        CGFloat oldY = oldFrame.origin.y + oldFrame.size.height;
        CGFloat newY = newFrame.origin.y + newFrame.size.height;
        CGFloat yDelta = newY - oldY;
        if (yDelta < -200) {// keyboard show
            _active = YES;
            _textView.text = _text;
            _placeHolderView.hidden = YES;
            _doneButton.enabled = YES;
        } else if (yDelta > 200) {// keyboard hide
            [self performSelector:@selector(noActived) withObject:nil afterDelay:0.3f];//键盘完全隐藏后，改为非激活状态
            _text = _textView.text;
            _textView.text = @"";
            _placeHolderView.hidden = NO;
            _doneButton.enabled = NO;
        }
        
        DLog(@"positon changed:%f %f", oldY, newY);
    }
}

- (void)noActived {
    _active = NO;
}

@end
