//
//  SlideShowDetailModel.h
//  Neonan
//
//  Created by capricorn on 12-11-9.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlideShowDetailModel : NSObject <Jsonable>
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *descriptions;
@property (strong, nonatomic) NSString *shareUrl;
@property (strong, nonatomic) NSArray *imgUrls;
@end
