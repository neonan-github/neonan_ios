//
//  MainSlideShowModel.h
//  Neonan
//
//  Created by capricorn on 12-11-8.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSSItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *contentId;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *imgUrl;

@end

@interface MainSlideShowModel : NSObject <Jsonable>

@property (strong, nonatomic) NSArray * list;

@end
