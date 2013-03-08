//
//  PurchaseVIPCell.m
//  Neonan
//
//  Created by capricorn on 13-3-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "PurchaseVIPCell.h"

#import <TTTAttributedLabel.h>

@interface PurchaseVIPCell ()

@property (nonatomic, weak) TTTAttributedLabel *titleLabel;

@end

@implementation PurchaseVIPCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.customBackgroundColor = HEXCOLOR(0x060606);
        self.borderColor = HEXCOLOR(0x222222);
        self.customSeparatorColor = HEXCOLOR(0x222222);
        self.selectionGradientStartColor = HEXCOLOR(0x222222);
        self.selectionGradientEndColor = HEXCOLOR(0x222222);
        self.dropsShadow = NO;
        
        self.contentView.backgroundColor = [UIColor clearColor];
        
        TTTAttributedLabel *titleLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(25, 0, self.width - 50, self.height)];
        self.titleLabel = titleLabel;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)setInfo:(NSString *)title priceRange:(NSRange)range {
    [_titleLabel setText:title afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)HEXCOLOR(0x0096ff).CGColor range:range];
        
        return mutableAttributedString;
    }];
}

@end
