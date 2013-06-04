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

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *textLabel;
@property (weak, nonatomic) IBOutlet KKGridView *gridView;

@end
