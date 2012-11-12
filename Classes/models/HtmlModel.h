//
//  HtmlModel.h
//  Neonan
//
//  Created by capricorn on 12-11-12.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HtmlModel : NSObject <Jsonable>
@property (strong, nonatomic) NSString *content;
@end
