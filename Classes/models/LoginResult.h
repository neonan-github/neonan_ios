//
//  LoginResult.h
//  HaHa
//
//  Created by capricorn on 12-12-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginResult : NSObject <Jsonable>

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *avatar;

@end
