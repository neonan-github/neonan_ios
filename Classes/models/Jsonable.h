//
//  Jsonable.h
//  Neonan
//
//  Created by capricorn on 12-11-2.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DCKeyValueObjectMapping.h>

@protocol Jsonable <NSObject>

+ (id<Jsonable>)parse:(NSDictionary *)JSON;

@end
