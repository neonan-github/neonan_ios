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
        self.highlightAlpha = 0.0f;
        
        CGFloat titleHeight = 19;
        
        UILabel *titleLabel = self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height - titleHeight, self.width, titleHeight)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        titleLabel.backgroundColor = RGBA(0, 0, 0, 0.7);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.text = @"阿鄂豫皖";
        [self.contentView addSubview:titleLabel];
        
        UILabel *rankLabel = self.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 30, self.height - titleHeight, 28, titleHeight)];
        rankLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        rankLabel.backgroundColor = [UIColor clearColor];
        rankLabel.textColor = [UIColor whiteColor];
        rankLabel.textAlignment = NSTextAlignmentRight;
        rankLabel.font = [UIFont systemFontOfSize:10];
        rankLabel.text = @"#99";
        [self.contentView addSubview:rankLabel];
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, self.width, 0.5)];
        bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        bottomLineView.backgroundColor = RGBA(255, 255, 255, 0.5);
        [self.contentView addSubview:bottomLineView];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setRank:(NSInteger)rank {
    _rankLabel.text = [NSString stringWithFormat:@"#%d", rank];
}

@end
