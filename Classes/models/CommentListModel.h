//
//  CommentListModel.h
//  Neonan
//
//  Created by capricorn on 12-11-14.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentItem : NSObject
@property (strong, nonatomic) NSString *visitor;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *dateMillis;

@property (readonly, nonatomic) NSString *date;

@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) BOOL expandable;
@end

@interface CommentListModel : NSObject <Jsonable>

@property (assign, nonatomic) NSUInteger totalCount;
@property (strong, nonatomic) NSArray *items;

@end
