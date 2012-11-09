//
//  ArticleDetailModel.h
//  Neonan
//
//  Created by capricorn on 12-11-9.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleDetailModel : NSObject <Jsonable>
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *author;
@property (assign, nonatomic) long dateMillis;
@property (assign, nonatomic) NSInteger commentNum;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *shareUrl;
@end
