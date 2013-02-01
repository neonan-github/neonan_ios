//
//  TopicDetailController.h
//  Neonan
//
//  Created by capricorn on 13-1-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicDetailController : UIViewController

@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, copy) NSString *detailId;
@property (nonatomic, copy) NSString *chName;
@property (nonatomic, assign) NSInteger rank;

@end
