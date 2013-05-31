//
//  HomeGridViewCell.m
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "HomeGridViewCell.h"

static const CGFloat kLabelHeight = 23;

@implementation HomeGridViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor blackColor];
        self.highlightAlpha = 0.0f;
        
        self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height - kLabelHeight);
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        TTTAttributedLabel *titleLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame),
                                                                                         frame.size.width, kLabelHeight)];
        self.titleLabel = titleLabel;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        titleLabel.backgroundColor = [UIColor blackColor];
        titleLabel.numberOfLines = 1;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.highlightedTextColor = HEXCOLOR(0x0096ff);
        titleLabel.font = [UIFont systemFontOfSize:12];
        
        CALayer *leftLineLayer = [CALayer layer];
        leftLineLayer.frame = CGRectMake(0, 0, 1, kLabelHeight);
        leftLineLayer.backgroundColor = HEXCOLOR(0x0096ff).CGColor;
        [titleLabel.layer addSublayer:leftLineLayer];
        
        [self.contentView addSubview:titleLabel];
    }
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.titleLabel.highlighted = self.highlighted || self.selected;
    self.imageView.layer.opacity = (self.selected || self.highlighted) ? 0.8 : 1;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.titleLabel.highlighted = self.selected || self.highlighted;
    self.imageView.layer.opacity = (self.selected || self.highlighted) ? 0.8 : 1;
}

- (void)setViewed:(BOOL)viewed {
    self.titleLabel.textColor = viewed ? HEXCOLOR(0x777777) : [UIColor whiteColor];
}

@end
