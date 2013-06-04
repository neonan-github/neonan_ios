//
//  GalleryOverView.m
//  Neonan
//
//  Created by capricorn on 13-6-4.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "GalleryOverView.h"

@interface GalleryOverView ()

@property (strong, nonatomic) IBOutlet UIView *tmpView;

@property (weak, nonatomic) IBOutlet UIButton *arrowButton;
@property (weak, nonatomic) IBOutlet UILabel *currentPageLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPageLabel;

@end

@implementation GalleryOverView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
