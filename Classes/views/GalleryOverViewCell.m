//
//  GalleryOverViewCell.m
//  Neonan
//
//  Created by capricorn on 13-6-6.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "GalleryOverViewCell.h"

@implementation GalleryOverViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.highlightAlpha = 0.0f;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.imageView.backgroundColor = RGBA(0, 0, 0, 0.7);
    }
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.imageView.layer.opacity = (self.selected || self.highlighted) ? 0.8 : 1;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.imageView.layer.opacity = (self.selected || self.highlighted) ? 0.8 : 1;
}

@end
