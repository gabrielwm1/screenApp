//
//  MovieSearchTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 11/7/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "MovieSearchTableViewCell.h"

@implementation MovieSearchTableViewCell

@synthesize imageView;
@synthesize delegate;

- (void)setImageURL:(NSURL *)url {
    [imageView sd_setImageWithURL:url];
}

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStatusButton)];
    [self.statusButton addGestureRecognizer:tap];
}

- (void)tapStatusButton {
    if ([delegate respondsToSelector:@selector(tappedAddButtonAtIndexPath:)]) {
        [delegate tappedAddButtonAtIndexPath:self.indexPath];
    }
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
