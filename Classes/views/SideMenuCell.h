//
//  SideMenuCell.h
//  Neonan
//
//  Created by capricorn on 13-5-29.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "PrettyTableViewCell.h"

typedef NS_ENUM(NSInteger, SideMenuCellStyle) {
    SideMenuCellStyleLeft = 0,
    SideMenuCellStyleRight,
};

@interface SideMenuCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, assign) SideMenuCellStyle cellStyle;

@end
