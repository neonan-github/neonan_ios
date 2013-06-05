//
//  GalleryOverView.h
//  Neonan
//
//  Created by capricorn on 13-6-4.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TTTAttributedLabel.h>
#import <KKGridView.h>

@interface GalleryOverView : UIView

@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) IBOutlet KKGridView *gridView;

@property (nonatomic, assign) BOOL expanded;

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

@end
