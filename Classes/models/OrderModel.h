//
//  OrderModel.h
//  Neonan
//
//  Created by capricorn on 13-3-11.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderModel : NSObject <Jsonable>

@property (strong, nonatomic) NSString *orderId;

@end
