//
//  NearTopicDetailsModel.h
//  Neonan
//
//  Created by Wu Yunpeng on 13-2-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TopicDetailModel.h"

@interface NearTopicDetailsModel : NSObject <Jsonable>

@property (strong, nonatomic) NSArray *items;

@end
