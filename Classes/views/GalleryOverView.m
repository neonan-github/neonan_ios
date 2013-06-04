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

@property (weak, nonatomic) IBOutlet UIButton *arrowButton;
@property (weak, nonatomic) IBOutlet UILabel *currentPageLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPageLabel;

@property (nonatomic, assign) BOOL expanded;

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

#pragma mark - Public methods

- (void)shrink {
    [UIView beginAnimations:nil context:NULL];
    self.height = 50;
    
    CGRect frame = self.textLabel.frame;
    frame.origin.x = 10;
    frame.origin.y = 0;
    frame.size.width = self.width - 102;
    frame.size.height = 50;
    self.textLabel.frame = frame;
    
    self.arrowButton.transform = CGAffineTransformMakeRotation(M_PI);
    
    [UIView commitAnimations];
}

- (void)expand {
    [UIView beginAnimations:nil context:NULL];
    self.height = CompatibleContainerHeight;
    
    CGRect frame = self.textLabel.frame;
    frame.origin.x = 10;
    frame.origin.y = 0;
    frame.size.width = 300;
    frame.size.height = 275;
    self.textLabel.frame = frame;
    
    self.arrowButton.transform = CGAffineTransformMakeRotation(0);
    
    [UIView commitAnimations];
}

#pragma mark - Private Event Handle

- (void)shrinkOrExpand {
    if (self.expanded) {
        [self shrink];
    } else {
        [self expanded];
    }
    
    self.expanded = !self.expanded;
}

#pragma mark - Private methods

- (void)setUp {
    [self.tmpView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
        [self addSubview:subview];
    }];
    self.tmpView = nil;
    
    self.clipsToBounds = YES;
    self.backgroundColor = RGBA(0, 0, 0, 0.7);
    
    [self.arrowButton addTarget:self
                         action:@selector(shrinkOrExpand)
               forControlEvents:UIControlEventTouchUpInside];
}

@end
