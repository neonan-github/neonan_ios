//
//  FoldableTextBox.m
//  WorkTest
//
//  Created by  on 12-10-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FoldableTextBox.h"

static const NSUInteger kMinNumberOfLines = 2;
static const NSUInteger kMaxNumberOfLines = 4;

@interface FoldableTextBox ()
- (BOOL)allowExpand;

- (void)shrink;
- (void)expand;

- (CGFloat)getFixPartHeight;

@property (nonatomic, assign) CGFloat bottomMargin;

@end

@implementation FoldableTextBox
@synthesize scrollView = _scrollView;
@synthesize arrowView = _arrowView;
@synthesize textLabel = _textLabel;
@synthesize expanded = _expanded;
@synthesize delegate = _delegate;

#pragma mark - init

- (void)setUp:(CGRect)frame {
    self.backgroundColor = RGBA(0, 0, 0, 0.5);
    
    CGFloat layoutY = 0;
    UIImageView *arrowView = self.arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 17, 5, 9, 7)];
    arrowView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    arrowView.image = [UIImage imageFromFile:@"icon_up_arrow_white.png"];
    [self addSubview:arrowView];
    
    layoutY += 20;
    UIScrollView *scrollView = self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, layoutY, frame.size.width, frame.size.height - layoutY)];
    [self addSubview:scrollView];
    
    UILabel *textLabel = self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:11];
    textLabel.text = @"杨棋涵毕业于中国音乐学院，有“小范冰冰”之称。以性感、冷艳、奢华、高贵等多种造型成为2010年娱乐媒体关注的焦点，更是频频亮相《男人装》、《瑞丽》、《时尚芭莎》等时尚杂志。杨棋涵毕业于中国音乐学院，有“小范冰冰”之称。以性感、冷艳、奢华、高贵等多种造型成为2010年娱乐媒体关注的焦点，更是频频亮相《男人装》、《瑞丽》、《时尚芭莎》等时尚杂志。";
    [scrollView addSubview:textLabel];
    
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp:frame];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp:self.frame];
}

#pragma mark - Accessors

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
        
    if (expanded && [self allowExpand]) {
        [self expand];
    } else {
        [self shrink];
    }
        
    if (_delegate) {
        [_delegate onFrameChanged:self.frame];
    }
}

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    
    CGRect frame = self.textLabel.frame;
    frame.origin.x += insets.left;
    frame.size.width -= insets.left + insets.right;
    self.textLabel.frame = frame;
    
    UIEdgeInsets contentInsets = self.scrollView.contentInset;
    contentInsets.left += insets.left;
    contentInsets.right -= insets.right;
    self.scrollView.contentInset = contentInsets;
    
    self.bottomMargin = insets.bottom;
    
    self.expanded = _expanded;
}

#pragma mark - Override methods

- (void)layoutSubviews {
    // resize scrollview
    CGRect frame = self.scrollView.frame;
    frame.origin.y = 20;
    frame.size.height = self.frame.size.height - [self getFixPartHeight];
    self.scrollView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, self.textLabel.frame.size.height);
    
    self.arrowView.hidden = ![self allowExpand];
    
    [super layoutSubviews];
}

#pragma mark - Public methods

- (CGFloat)getSuggestedHeight {
    return kMinNumberOfLines * self.textLabel.font.lineHeight + [self getFixPartHeight];
}

#pragma mark - Private methods
- (NSUInteger)computeContentLines {
    return [UIHelper computeContentLines:self.textLabel.text withWidth:self.textLabel.frame.size.width andFont:self.textLabel.font];
}

- (BOOL)allowExpand {
    return [self computeContentLines] > kMinNumberOfLines;
}

- (CGFloat)getFixPartHeight {
    return 20 + self.bottomMargin;
}

- (void)expand {
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self.textLabel sizeToFit];
    
    CGFloat scrollViewHeight = MIN(self.textLabel.font.lineHeight * kMaxNumberOfLines, self.textLabel.frame.size.height);
    
    [UIView beginAnimations:nil context:nil];
    CGRect frame = self.frame;
    frame.size.height = [self getFixPartHeight] + scrollViewHeight;
    self.frame = frame;
    
    _arrowView.transform = CGAffineTransformMakeRotation(M_PI);
    [UIView commitAnimations];
}

- (void)shrink {
    NSUInteger lines = MIN([self computeContentLines], 2);
    self.textLabel.numberOfLines = lines;
    self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    CGFloat scrollViewHeight = self.textLabel.font.lineHeight * lines;
    CGRect frame = self.textLabel.frame;
    frame.size.height = scrollViewHeight;
    self.textLabel.frame = frame;
    
    [UIView beginAnimations:nil context:nil];
    frame = self.frame;
    frame.size.height = [self getFixPartHeight] + scrollViewHeight;
    self.frame = frame;
    
    _arrowView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    self.expanded = !self.expanded;
}

@end
