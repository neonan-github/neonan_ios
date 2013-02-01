//
//  TopicDetailModel.h
//  Neonan
//
//  Created by capricorn on 13-2-1.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicDetailModel : NSObject <Jsonable>

@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *enName;
@property (nonatomic, assign) NSInteger upCount;
@property (nonatomic, assign) NSInteger downCount;
@property (nonatomic, strong) NSString *imageUrl;

@end
