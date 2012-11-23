//
//  NearWorksModel.h
//  Neonan
//
//  Created by capricorn on 12-11-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NearItem : NSObject
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *contentId;
@property (assign, nonatomic) NSInteger offset;
@end

@interface NearWorksModel : NSObject <Jsonable>
@property (strong, nonatomic) NSArray *items;

- (void)insertMoreData:(NearWorksModel *)data withMode:(BOOL)append;
@end
