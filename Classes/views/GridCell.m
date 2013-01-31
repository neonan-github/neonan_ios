//
//  GridCell.m
//  Neonan
//
//  Created by capricorn on 13-1-31.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "GridCell.h"

@interface GridCell ()

@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UILabel *rankLabel;

@end

@implementation GridCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *titleLabel = self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height - 20, self.width, 20)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        titleLabel.backgroundColor = RGBA(0, 0, 0, 0.7);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"阿鄂豫皖";
        [self.contentView addSubview:titleLabel];
        
        UILabel *rankLabel = self.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 30, self.height - 20, 25, 20)];
        rankLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        rankLabel.backgroundColor = [UIColor clearColor];
        rankLabel.textColor = [UIColor whiteColor];
        rankLabel.textAlignment = NSTextAlignmentRight;
        rankLabel.text = @"#99";
        [self.contentView addSubview:rankLabel];
    }
    return self;
}

@end
