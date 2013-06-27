//
//  SideMenuCell.m
//  Neonan
//
//  Created by capricorn on 13-5-29.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "SideMenuCell.h"

@interface SideMenuCell ()

@end

@implementation SideMenuCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.frame];
        self.backgroundView = bgImageView;
        
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.x = 20;
    self.imageView.width = 30;
    self.imageView.height = 30;
    [self.imageView setCenterY:self.contentView.center.y];
    
    self.textLabel.x -= self.cellStyle == SideMenuCellStyleLeft ? (self.imageView.image ? 80 : 60) : -60;
}

@end
