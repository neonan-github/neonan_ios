//
//  SignResult.h
//  Neonan
//
//  Created by capricorn on 12-11-2.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"

@interface SignResult : NSObject <Jsonable>

@property (strong, nonatomic) NSString *token;

@end
