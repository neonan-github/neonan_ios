//
//  OrderError.h
//  Neonan
//
//  Created by capricorn on 13-3-13.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderError : NSObject <Jsonable>

@property (nonatomic, assign) NSInteger error;
@property (nonatomic, assign) NSInteger status;

@end
