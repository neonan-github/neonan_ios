//
//  FunctionFlowView.m
//  Neonan
//
//  Created by capricorn on 13-3-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "FunctionFlowView.h"

@interface FunctionFlowView ()

@property (weak, nonatomic) IBOutlet UIView *tmpView;

@end

@implementation FunctionFlowView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"FunctionFlowView" owner:self options:nil];
        [self setUp];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inside = [super pointInside:point withEvent:event];
    DLog(@"inside:%d", inside);
    if (!inside) {
        [self removeFromSuperview];
    }
    
    return inside;
}

- (void)setFavorited:(BOOL)favorited {
    [_favButton setTitle:favorited ? @"取消" : @"收藏" forState:UIControlStateNormal];
    
    [_favButton setTitleColor:favorited ? HEXCOLOR(0x0095ff) : [UIColor whiteColor] forState:UIControlStateNormal];
    [_favButton setTitleColor:!favorited ? HEXCOLOR(0x0095ff) : [UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [_favButton setImage:[UIImage imageNamed:favorited ? @"icon_fav_highlighted.png" : @"icon_fav_normal.png"] forState:UIControlStateNormal];
    [_favButton setImage:[UIImage imageNamed:!favorited ? @"icon_fav_highlighted.png" : @"icon_fav_normal.png"] forState:UIControlStateHighlighted];
}

#pragma mark - Private methods

- (void)setUp {
    self.userInteractionEnabled = YES;
    
    self.image = [UIImage imageFromFile:@"bg_function_flow.png"];
    
    [self.tmpView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
        [self addSubview:subview];
    }];
    self.tmpView = nil;
}

@end
