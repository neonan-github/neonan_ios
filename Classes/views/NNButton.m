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
        if ([view respondsToSelector:@selector(setHighlighted:)]) {
            [view setHighlighted:highlighted];
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    for (id view in self.subviews) {
        if ([view respondsToSelector:@selector(setSelected:)]) {
            [view setSelected:selected];
        }
    }
}

@end
