//
//  LockManager.h
//  Neonan
//
//  Created by capricorn on 13-7-4.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LockManager : NSObject

@property (nonatomic, readonly, getter = isContentLocked) BOOL contentLocked;// 是否屏蔽女人、性感地带，审核期间

+ (LockManager *)sharedManager;

- (void)validateContentLock;

@end
