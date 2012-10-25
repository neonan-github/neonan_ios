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
@property (nonatomic, unsafe_unretained) HPGrowingTextView *textView;
@property (nonatomic, unsafe_unretained) UIView *rightView;
@property (nonatomic, unsafe_unretained) UIButton *doneButton;
@property (nonatomic, unsafe_unretained) UIImageView *placeHolderView;

@property (nonatomic, strong) NSString *text;
@end
