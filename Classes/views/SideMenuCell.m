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
        bgImageView.image = [[UIImage imageFromFile:@"bg_menu_cell.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 1, 0)];
        self.backgroundView = bgImageView;
        
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.x -= self.cellStyle == SideMenuCellStyleLeft ? 60 : -60;
}

@end
