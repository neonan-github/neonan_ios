//
//  ResponseError.h
//  Neonan
//
//  Created by capricorn on 12-11-2.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseError : NSObject

@property (assign, nonatomic) NSInteger errorCode;
@property (strong, nonatomic) NSString *message;

@end
