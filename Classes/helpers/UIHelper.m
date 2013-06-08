//
//  UIHelper.m
//  Neonan
//
//  Created by capricorn on 12-10-18.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "UIHelper.h"

@implementation UIHelper
+ (void)fitScrollView:(UIScrollView *)scrollView withMaxHeight:(float)maxHeight {
    CGRect frame = scrollView.frame;
    frame.size.height = MIN(maxHeight, scrollView.contentSize.height);
    scrollView.frame = frame;
}

+ (void)view:(UIView *)view alignBottomTo:(float)bottom {
    CGRect frame = view.frame;
    frame.origin.y = bottom - frame.size.height;
    view.frame = frame;
}

+ (NSUInteger)computeContentLines:(NSString *)content withWidth:(CGFloat)width andFont:(UIFont *)font {
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [content sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return  (NSUInteger)(size.height / font.lineHeight);
}

+ (CGFloat)computeHeightForLabel:(UILabel *)label withText:(NSString *)text {
    CGFloat originalHeight = label.frame.size.height;
    
    NSInteger originalLines = [UIHelper computeContentLines:label.text withWidth:label.frame.size.width andFont:label.font];
    NSInteger newlines = [UIHelper computeContentLines:text withWidth:label.frame.size.width andFont:label.font];
    
    return originalHeight + (newlines - (originalLines > 0 ? originalLines : 1)) * label.font.lineHeight;
}

+ (void)setBackAction:(SEL)action forController:(UIViewController *)controller withImage:(UIImage *)image {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

+ (UIButton *)createBarButtonWithWidth:(CGFloat)width andHeight:(CGFloat)height {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 3.0, 0, 3.0);
    
    button.frame = CGRectMake(0, 0, width, height);
    
//    [button setBackgroundImage:[[UIImage imageFromFile:@"bg_nav_bar_item_normal.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:14]
//                      forState:UIControlStateNormal];
//    [button setBackgroundImage:[[UIImage imageFromFile:@"bg_nav_bar_item_highlighted.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:14]
//                      forState:UIControlStateHighlighted];
//    [button setBackgroundImage:[[UIImage imageFromFile:@"bg_nav_bar_item_highlighted.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:14]
//                      forState:UIControlStateSelected];
    
    return button;
}

+ (UIButton *)createBackButton:(UINavigationBar *)navigationBar {
    UIButton *button = [UIHelper createLeftBarButton:@"icon_nav_back.png"];
    [button addTarget:navigationBar action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UIButton *)createLeftBarButton:(NSString *)imageName {
    UIButton *button = [UIHelper createBarButtonWithWidth:30 andHeight:30];
    
    CGFloat inset = 0;
    button.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    
    if (imageName) {
        UIImage *iconImage = [UIImage imageFromFile:imageName];
        [button setImage:iconImage forState:UIControlStateNormal];
//        [button setImage:iconImage forState:UIControlStateHighlighted];
    }
    
    return button;
}

+ (UIButton *)createRightBarButton:(NSString *)imageName {
    UIButton *button = [UIHelper createBarButtonWithWidth:30 andHeight:30];
    
    CGFloat inset = 0;
    button.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    
    if (imageName) {
        UIImage *iconImage = [UIImage imageFromFile:imageName];
        [button setImage:iconImage forState:UIControlStateNormal];
//        [button setImage:iconImage forState:UIControlStateHighlighted];
    }
    
    return button;
}

+ (UIView *)createLogoView {
    UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, NavBarHeight)];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 107, 25)];
    imgView.center = logoView.center;
    imgView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    imgView.image = [UIImage imageFromFile:@"img_logo.png"];
    [logoView addSubview:imgView];
    
    return logoView;
}

+ (MarqueeLabel *)createNavMarqueeLabel {
    MarqueeLabel *titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, 240, 20) duration:5 andFadeLength:8];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.animationDelay = 0.5;
    titleLabel.animationCurve = UIViewAnimationCurveLinear;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.marqueeType = MLContinuous;
    [titleLabel performSelector:@selector(setTapToScroll:) withObject:@(YES) afterDelay:5]; // only auto scroll once
    
    return titleLabel;
}

+ (UIView *)defaultAccessoryView {
    UIView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_default_accessory.png"]];
    accessoryView.width = 30;
    accessoryView.height = 30;
    
    return accessoryView;
}

+ (void)alertWithMessage:(NSString *)message {
    static UIAlertView *alertView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    });
    
    alertView.message = message;
    [alertView show];
}

+ (CAAnimation *)createBounceAnimation:(NNDirection)direction {
    // these three values are subject to experimentation
	CGFloat initialMomentum = 150.0f; // positive is upwards, per sec
	CGFloat gravityConstant = 250.0f; // downwards pull per sec
	CGFloat dampeningFactorPerBounce = 0.0;  // percent of rebound
    
	// internal values for the calculation
	CGFloat momentum = initialMomentum; // momentum starts with initial value
	CGFloat positionOffset = 0; // we begin at the original position
	CGFloat slicesPerSecond = 10.0f; // how many values per second to calculate
	CGFloat lowerMomentumCutoff = 5.0f; // below this upward momentum animation ends
    
	CGFloat duration = 0;
	NSMutableArray *values = [NSMutableArray array];
    
    CGFloat xFactor = 0, yFactor = 0;
    if (direction == NNDirectionLeft) {
        xFactor = 1;
    } else if (direction == NNDirectionRight) {
        xFactor = -1;
    } else if (direction == NNDirectionTop) {
        yFactor = 1;
    } else {// bottom
        yFactor = -1;
    }
    
	do
	{
		duration += 0.3f/slicesPerSecond;
		positionOffset+=momentum/slicesPerSecond;
        
		if (positionOffset<0)
		{
			positionOffset=0;
			momentum=-momentum*dampeningFactorPerBounce;
		}
        
		// gravity pulls the momentum down
		momentum -= gravityConstant/slicesPerSecond;
        
		CATransform3D transform = CATransform3DMakeTranslation(xFactor * positionOffset, yFactor * positionOffset, 0);
		[values addObject:[NSValue valueWithCATransform3D:transform]];
	} while (!(positionOffset==0 && momentum < lowerMomentumCutoff));
    
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	animation.repeatCount = 1;
	animation.duration = duration;
	animation.fillMode = kCAFillModeForwards;
	animation.values = values;
	animation.removedOnCompletion = YES; // final stage is equal to starting stage
	animation.autoreverses = NO;

    return animation;
}

+ (CALayer *)layerWithName:(NSString *)name inView:(UIView *)view {
    for (CALayer *layer in [view.layer sublayers]) {
        DLog(@"layer name: %@", layer.name);
        if ([[layer name] isEqualToString:name]) {
            return layer;
        }
    }
        
    return nil;
}

@end

@implementation UIImage (UIImageUtil)

+ (UIImage *)imageFromFile:(NSString *)fileName {
    NSArray *splits = [fileName componentsSeparatedByString:@"."];
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:[splits objectAtIndex:0] ofType:[splits objectAtIndex:1]];
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    return [UIImage imageWithData:imageData];
}

+ (UIImage *)imageFromView:(UIView *)view {
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(view.frame.size);
    }
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation UIView (FrameUtil)

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)newOrigin {
    CGRect newFrame = self.frame;
    newFrame.origin = newOrigin;
    self.frame = newFrame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)newSize {
    CGRect newFrame = self.frame;
    newFrame.size = newSize;
    self.frame = newFrame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)newX {
    CGRect newFrame = self.frame;
    newFrame.origin.x = newX;
    self.frame = newFrame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)newY {
    CGRect newFrame = self.frame;
    newFrame.origin.y = newY;
    self.frame = newFrame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newHeight {
    CGRect newFrame = self.frame;
    newFrame.size.height = newHeight;
    self.frame = newFrame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newWidth {
    CGRect newFrame = self.frame;
    newFrame.size.width = newWidth;
    self.frame = newFrame;
}

- (void)setCenterXY:(void (^)(CGPoint *center))block {
    CGPoint center = self.center;
    block(&center);
    self.center = center;
}

- (void)setCenterX:(CGFloat)newCenterX {
    [self setCenterXY:^(CGPoint *center) {
        (*center).x = newCenterX;
    }];
}

- (void)setCenterY:(CGFloat)newCenterY {
    [self setCenterXY:^(CGPoint *center) {
        (*center).y = newCenterY;
    }];
}

@end

