//
//  NSString+TruncateToWidth.m
//  Neonan
//
//  Created by capricorn on 12-10-18.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NSString+TruncateToWidth.h"

#define defaultEllipsis @"…"

@implementation NSString (TruncateToWidth)

- (NSString*)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont *)font andEllipsis:(NSString *)ellipsis
{
    ellipsis = ellipsis ? ellipsis : defaultEllipsis;
    // Create copy that will be the returned result
    NSMutableString *truncatedString = [[self mutableCopy] autorelease];
    
    // Make sure string is longer than requested width
    if ([self sizeWithFont:font].width > width)
    {
        // Accommodate for ellipsis we'll tack on the end
        width -= [ellipsis sizeWithFont:font].width;
        
        // Get range for last character in string
        NSRange range = {truncatedString.length - 1, 1};
        
        // Loop, deleting characters until string fits within width
        while ([truncatedString sizeWithFont:font].width > width)
        {
            // Delete character at end
            [truncatedString deleteCharactersInRange:range];
            
            // Move back another character
            range.location--;
        }
        
        // Append ellipsis
        [truncatedString replaceCharactersInRange:range withString:ellipsis];
    }
    
    return truncatedString;
}

@end
