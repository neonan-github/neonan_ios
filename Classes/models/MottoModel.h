//
//  MottoModel.h
//  Neonan
//
//  Created by capricorn on 13-6-25.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"

@interface MottoModel : NSObject <Jsonable, NSCoding>

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *content;

@end
