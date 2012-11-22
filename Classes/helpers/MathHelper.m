//
//  MathHelper.m
//  Neonan
//
//  Created by capricorn on 12-11-5.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "MathHelper.h"

@implementation MathHelper

+ (CGFloat)floorValue:(CGFloat)value withDecimal:(NSUInteger)dec {
    NSUInteger scale = 1;
    for (NSUInteger i = 0; i < dec; i++) {
        scale *= 10;
    }
    
    return floorf(value * scale) / scale;
}

@end
