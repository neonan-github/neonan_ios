//
//  BabyListModel.h
//  Neonan
//
//  Created by capricorn on 12-11-8.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BabyItem : NSObject

@property (strong, nonatomic) NSString *contentId;
@property (strong, nonatomic) NSString *babyName;
@property (strong, nonatomic) NSArray *list;

@end

@interface BabyListModel : NSObject <Jsonable>

@property (assign, nonatomic) NSUInteger totalCount;
@property (strong, nonatomic) NSArray *list;

@end
