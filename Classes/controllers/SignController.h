//
//  SignController.h
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>

typedef enum {
    signIn = 0,
    signUp
} signType;

typedef void(^SignSuccessBlock)(NSString *token);

@interface SignController : UIViewController <TTTAttributedLabelDelegate>

@property (assign, nonatomic) signType type;
@property (copy, nonatomic) SignSuccessBlock success;

- (id)initWithType:(signType)type;

@end
