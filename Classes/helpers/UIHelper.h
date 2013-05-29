//
//  UIHelper.h
//  Neonan
//
//  Created by capricorn on 12-10-18.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NNNavigationBar.h"

#define NavBar                              self.navigationController.navigationBar
#define TabBar                              self.tabBarController.tabBar
#define NavBarHeight                        44
#define StatusBarHeight                     20
#define KeyboardPortraitHeight              216
#define TabBarHeight                        self.tabBarController.tabBar.bounds.size.height
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define CompatibleScreenWidth               (ScreenWidth > 320) ? (ScreenWidth / 2) : ScreenWidth
#define CompatibleScreenHeight              (ScreenWidth > 320) ? (ScreenHeight / 2) : ScreenHeight
#define CompatibleContainerHeight           CompatibleScreenHeight - StatusBarHeight - NavBarHeight 
#define TouchHeightDefault                  44
#define TouchHeightSmall                    32
#define ViewWidth(v)                        v.frame.size.width
#define ViewHeight(v)                       v.frame.size.height
#define ViewX(v)                            v.frame.origin.x
#define ViewY(v)                            v.frame.origin.y
#define SelfViewWidth                       self.view.bounds.size.width
#define SelfViewHeight                      self.view.bounds.size.height
#define RectX(f)                            f.origin.x
#define RectY(f)                            f.origin.y
#define RectWidth(f)                        f.size.width
#define RectHeight(f)                       f.size.height
#define RectSetWidth(f, w)                  CGRectMake(RectX(f), RectY(f), w, RectHeight(f))
#define RectSetHeight(f, h)                 CGRectMake(RectX(f), RectY(f), RectWidth(f), h)
#define RectSetX(f, x)                      CGRectMake(x, RectY(f), RectWidth(f), RectHeight(f))
#define RectSetY(f, y)                      CGRectMake(RectX(f), y, RectWidth(f), RectHeight(f))
#define RectSetSize(f, w, h)                CGRectMake(RectX(f), RectY(f), w, h)
#define RectSetOrigin(f, x, y)              CGRectMake(x, y, RectWidth(f), RectHeight(f))
#define RGB(r, g, b)                        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HEXCOLOR(c)                         [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]

#define DarkThemeColor                      HEXCOLOR(0x121212)

typedef enum {
    NNDirectionLeft = 0,
    NNDirectionTop,
    NNDirectionRight,
    NNDirectionBottom
} NNDirection;

@interface UIHelper : NSObject
+ (void)fitScrollView:(UIScrollView *)scrollView withMaxHeight:(float)maxHeight;// make scrollview sizeToFit

+ (void)view:(UIView *)view alignBottomTo:(float)bottom;

+ (NSUInteger)computeContentLines:(NSString *)content withWidth:(CGFloat)width andFont:(UIFont *)font;
+ (CGFloat)computeHeightForLabel:(UILabel *)label withText:(NSString *)text;

+ (UIButton *)createBackButton:(UINavigationBar *)navigationBar;
+ (UIButton *)createLeftBarButton:(NSString *)imageName;
+ (UIButton *)createRightBarButton:(NSString *)imageName;

+ (void)alertWithMessage:(NSString *)message;

+ (CAAnimation *)createBounceAnimation:(NNDirection)direction;

+ (CALayer *)layerWithName:(NSString *)name inView:(UIView *)view;

@end

@interface UIImage (UIImageUtil)

+ (UIImage *)imageFromFile:(NSString *)fileName;
+ (UIImage *)imageFromView:(UIView *)view;

@end

@interface UIView (FrameUtil)

- (CGPoint)origin;
- (void)setOrigin:(CGPoint)newOrigin;
- (CGSize)size;
- (void)setSize:(CGSize)newSize;

- (CGFloat)x;
- (void)setX:(CGFloat)newX;
- (CGFloat)y;
- (void)setY:(CGFloat)newY;

- (CGFloat)height;
- (void)setHeight:(CGFloat)newHeight;
- (CGFloat)width;
- (void)setWidth:(CGFloat)newWidth;

- (void)setCenterX:(CGFloat)newCenterX;
- (void)setCenterY:(CGFloat)newCenterY;

@end
