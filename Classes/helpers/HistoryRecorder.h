//
//  HistoryRecorder.h
//  Neonan
//
//  Created by capricorn on 13-3-2.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject

@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *contentId;

@end

@interface HistoryRecorder : NSObject

+ (HistoryRecorder *)sharedRecorder;

- (BOOL)isRecorded:(Record *)record;
- (void)saveRecord:(Record *)record;

@end
