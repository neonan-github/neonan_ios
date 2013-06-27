//
//  NNDefaultCell.m
//  Neonan
//
//  Created by capricorn on 13-6-3.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "NNDefaultCell.h"

@implementation NNDefaultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.customBackgroundColor = DarkThemeColor;
        self.customSeparatorColor = HEXCOLOR(0x1d1d1d);
        self.selectionGradientStartColor = HEXCOLOR(0x1e1e1e);
        self.selectionGradientEndColor = HEXCOLOR(0x1e1e1e);
        
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont systemFontOfSize:17];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    self.detailTextLabel.x += (self.accessoryView ? 15 : 0);
//    self.accessoryView.y += (self.position != PrettyTableViewCellPositionBottom &&
//                             self.position != PrettyTableViewCellPositionAlone ? 2 : 0);
}

@end
