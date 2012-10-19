//
//  CommentBox.h
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HPGrowingTextView.h>

@interface CommentBox : UIView <HPGrowingTextViewDelegate>
@property (nonatomic, retain) HPGrowingTextView *textView;
@end
