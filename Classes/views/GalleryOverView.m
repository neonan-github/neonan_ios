//
//  GalleryOverView.m
//  Neonan
//
//  Created by capricorn on 13-6-4.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "GalleryOverView.h"

@interface GalleryOverView ()

@property (strong, nonatomic) IBOutlet UIView *tmpView;

@property (weak, nonatomic) UIView *textLabelContainerView;
@property (weak, nonatomic) IBOutlet UIButton *arrowButton;
@property (weak, nonatomic) IBOutlet UILabel *currentPageLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPageLabel;

@end

@implementation GalleryOverView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"GalleryOverView" owner:self options:nil];
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (void)setExpanded:(BOOL)expanded {
    [self setExpanded:expanded animated:NO];
}

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated {
    void (^block)() = ^{
        self.frame = CGRectMake(0, 0, self.width, expanded ? self.superview.height : 50);
        self.textView.frame = CGRectMake(0, 0, self.width - (expanded ? 0 : 87), expanded ? 120 : 40);
        
        self.arrowButton.transform = CGAffineTransformMakeRotation(expanded ? 0 : M_PI);
    };
    
    if (animated) {
        self.tmpView.layer.opacity = 1;
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.textView.layer.opacity = 0.5;
                             block();
                             self.textView.layer.opacity = 1;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        block();
    }
    
    _expanded = expanded;
}

- (void)setCurrentPage:(NSInteger)currentPage totalPage:(NSInteger)totalPage {
    self.currentPageLabel.text = [NSString stringWithFormat:@"%d", currentPage];
    self.totalPageLabel.text = [NSString stringWithFormat:@"%d", totalPage];
}

#pragma mark - Private Event Handle

- (void)shrinkOrExpand {
    [self setExpanded:!self.expanded animated:YES];
}

#pragma mark - Private methods

- (void)setUp {
    self.clipsToBounds = YES;
    self.backgroundColor = RGBA(0, 0, 0, 0.5);
    
    self.tmpView.bounds = self.bounds;
    [self.tmpView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
        [self addSubview:subview];
    }];
    self.tmpView = nil;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.width - (self.expanded ? 0 : 87), self.expanded ? 120 : 40)];
    self.textView = textView;
    textView.userInteractionEnabled = NO;
    textView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    textView.font = [UIFont systemFontOfSize:15];
    textView.textColor = [UIColor whiteColor];
    textView.backgroundColor = [UIColor clearColor];
    [self addSubview:textView];
    
    [self.arrowButton addTarget:self
                         action:@selector(shrinkOrExpand)
               forControlEvents:UIControlEventTouchUpInside];
    
    self.gridView.clipsToBounds = YES;
    self.gridView.cellPadding = CGSizeMake(2, 2);
    self.gridView.cellSize = CGSizeMake(58, 58);
    self.gridView.backgroundView = nil;
    self.gridView.backgroundColor = [UIColor clearColor];
}

@end
