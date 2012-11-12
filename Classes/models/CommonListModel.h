//
//  CommenListModel.h
//  Neonan
//
//  Created by capricorn on 12-11-9.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonItem : NSObject

@property (strong, nonatomic) NSString *thumbUrl;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) NSNumber *dateMillis;

@property (readonly, nonatomic) NSString *date;
@end

@interface CommonListModel : NSObject <Jsonable>

@property (assign, nonatomic) NSUInteger totalCount;
@property (strong, nonatomic) NSArray *items;

@end
