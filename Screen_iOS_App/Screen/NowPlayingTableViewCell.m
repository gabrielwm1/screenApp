//
//  NowPlayingTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 1/9/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "NowPlayingTableViewCell.h"
#import "Constants.h"

@implementation NowPlayingTableViewCell

@synthesize imageView;
@synthesize indexPath;
@synthesize delegate;
@synthesize separator;

- (void)tapStatusButton {

    if ([delegate respondsToSelector:@selector(tappedAddButtonOnCell:)]) {
        [delegate tappedAddButtonOnCell:self];
    }
}

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapStatusButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStatusButton)];
    [self.statusButton addGestureRecognizer:tapStatusButton];
    
    separator = [[UIView alloc] init];
    [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    separator.backgroundColor = [UIColor whiteColor];
    separator.alpha = .7f;
    [self.contentView addSubview:separator];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[separator]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separator(0.5)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];
}

- (UIView *)selectionBackground {
    if (!selectionBackground) {
        selectionBackground = [[UIView alloc] initWithFrame:self.contentView.bounds];
        selectionBackground.backgroundColor = UIColorFromRGB(cellSelectColor);
        selectionBackground.alpha = 0.0f;
        
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        
        CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
        CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        
        maskLayer.colors = [NSArray arrayWithObjects:(__bridge id)outerColor,
                            (__bridge id)innerColor, (__bridge id)innerColor, (__bridge id)outerColor, nil];
        maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.1],
                               [NSNumber numberWithFloat:0.9],
                               [NSNumber numberWithFloat:1.0], nil];
        
        maskLayer.bounds = CGRectMake(0, 0,
                                      self.contentView.frame.size.width,
                                      self.contentView.frame.size.height);
        maskLayer.anchorPoint = CGPointZero;
        
        selectionBackground.layer.mask = maskLayer;
        
        
        [self.contentView insertSubview:selectionBackground atIndex:0];
    }
    
    return selectionBackground;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //    [super setHighlighted:highlighted animated:animated];
    
    [[self selectionBackground] setAlpha:(highlighted)?1.0f:0.0f];
    //    self.contentView.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    //    self.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (animated) {
        [UIView animateWithDuration:.2f animations:^{
            self.contentView.backgroundColor = (selected)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
        }];
    } else {
        self.contentView.backgroundColor = (selected)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    }
}

@end
