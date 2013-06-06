//
//  NNTextField.m
//  Neonan
//
//  Created by capricorn on 13-3-27.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNTextField.h"

@implementation NNTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    [self.placeholderColor setFill];
    [self.placeholder drawInRect:rect
                        withFont:self.font
                   lineBreakMode:UILineBreakModeTailTruncation
                       alignment:self.textAlignment];
}

- (UIColor *)placeholderColor {
    if (!_placeholderColor) {
        _placeholderColor = [UIColor lightTextColor];
    }
    
    return _placeholderColor;
}

@end
