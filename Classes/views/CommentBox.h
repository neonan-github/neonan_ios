//
//  CommentBox.h
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HPGrowingTextView.h>

@interface CommentBox : UIView <HPGrowingTextViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) UIButton *countButton;
@property (nonatomic, weak) HPGrowingTextView *textView;
@property (nonatomic, weak) UIView *rightView;
@property (nonatomic, weak) UIButton *doneButton;
@property (nonatomic, weak) UIImageView *placeHolderView;

@property (nonatomic, copy) NSString *text;

@end
