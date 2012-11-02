//
//  MD5.h
//  Neonan
//
//  Created by capricorn on 12-11-2.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)
- (NSString *) md5;
@end

@interface NSData (MD5)
- (NSString*)md5;
@end
