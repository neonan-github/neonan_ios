//
//  NNDropDownMenu.h
//  Neonan
//
//  Created by capricorn on 12-12-10.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NNMenuItem : UIControl

- (void)setIconImage:(UIImage *)image andHighlightedImage:(UIImage *)highlightedImage;
- (void)setText:(NSString *)text withColor:(UIColor *)color andHighlightedColor:(UIColor *)highlightedColor;
- (void)setText:(NSString *)text;

@end

typedef void(^ItemClickedBlock)(NNMenuItem *item, NSUInteger index);

@protocol NNDropDownMenuDelegate <NSObject>

@optional
- (void)onMenuDismissed;

@end

@interface NNDropDownMenu : UIWindow
@property (nonatomic, assign) CGFloat topPadding;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign, getter = isShowing) BOOL showing;
@property (nonatomic, readonly) NSArray *items;

@property (nonatomic, unsafe_unretained) id<NNDropDownMenuDelegate> menuDelegate;

@property (nonatomic, copy) ItemClickedBlock onItemClicked;

- (void)addItem:(NNMenuItem *)item;
- (void)showMenu;
- (void)dismissMenu;

@end


