//
//  FoldableTextBox.h
//  WorkTest
//
//  Created by  on 12-10-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FoldableTextBoxDelegate <NSObject>

- (void)onFrameChanged:(CGRect)frame;

@end

@interface FoldableTextBox : UIView
@property (nonatomic, unsafe_unretained) UIScrollView *scrollView;
@property (nonatomic, unsafe_unretained) UIImageView *arrowView;

@property (nonatomic, assign, getter = isExpanded) BOOL expanded;

@property (nonatomic, unsafe_unretained) id<FoldableTextBoxDelegate> delegate;

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, copy) NSString *text;

- (CGFloat)getSuggestedHeight;
@end
