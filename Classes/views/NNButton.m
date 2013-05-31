//
//  NNButton.m
//  Neonan
//
//  Created by capricorn on 13-5-27.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNButton.h"

@implementation NNButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    for (id view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            ((UIImageView *)view).layer.opacity = highlighted ? 0.8 : 1;
        }
        
        if ([view respondsToSelector:@selector(setHighlighted:)]) {
            [view setHighlighted:highlighted];
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    for (id view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            ((UIImageView *)view).layer.opacity = selected ? 0.8 : 1;
        }
        
        if ([view respondsToSelector:@selector(setSelected:)]) {
            [view setSelected:selected];
        }
    }
}

- (void)setViewed:(BOOL)viewed {
    for (id view in self.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            ((UILabel *)view).textColor = viewed ? HEXCOLOR(0x777777) : [UIColor whiteColor];
        }
    }
}

@end
