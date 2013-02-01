//
//  TopicGridsModel.h
//  Neonan
//
//  Created by capricorn on 13-2-1.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"

@interface TopicItem : NSObject

@property (nonatomic, strong) NSString *contentId;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger ranking;

@end

@interface TopicGridsModel : NSObject <Jsonable>

@property (assign, nonatomic) NSUInteger totalCount;
@property (strong, nonatomic) NSArray *items;

- (void)appendMoreData:(TopicGridsModel *)data;

@end
