//
//  UserInfoModel.h
//  Bang
//
//  Created by capricorn on 13-1-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject <Jsonable, NSCoding>

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, assign) NSInteger point;
@property (nonatomic, assign) NSInteger exp;
@property (nonatomic, assign) NSInteger rank;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, strong) NSNumber *expiration;
@property (nonatomic, assign, getter = isVip) BOOL vip;

@property (nonatomic, readonly) NSString *expirationText;

@end
