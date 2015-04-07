//
//  ShowtimeTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 12/3/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "ShowtimeTableViewCell.h"
#import <PureLayout/PureLayout.h>

@implementation ShowtimeTableViewCell

@synthesize separator;
@synthesize titleLabel;
@synthesize timesLabel;
@synthesize distanceLabel;

- (void)awakeFromNib {
    // Initialization code
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];

    separator = [[UIView alloc] init];
    separator.backgroundColor = [UIColor whiteColor];
    separator.alpha = .5f;
    [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:separator];

    // align separator from the left and right
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[separator]-13-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];
    
    // align separator from the bottom
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separator(==0.5)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];

}

- (void)updateConstraints {
    if (!didUpdateContstraints) {
        didUpdateContstraints = YES;
        
//        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[titleLabel]-6-[timesLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel, timesLabel)]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:distanceLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-21-[titleLabel]->=8-[distanceLabel]-14-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel, distanceLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-21-[timesLabel]-21-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(timesLabel)]];
        
        [titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [distanceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[separator]-13-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separator(==0.5)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];

    }
    
    [super updateConstraints];
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
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    selectionBackground.frame = self.contentView.bounds;
    selectionBackground.layer.mask.bounds = self.contentView.bounds;
    [CATransaction commit];
    
    return selectionBackground;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
//        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        NSLog(@"init with style showtime cell");
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        titleLabel = [UILabel newAutoLayoutView];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [self.contentView addSubview:titleLabel];
        
        distanceLabel = [UILabel newAutoLayoutView];
        distanceLabel.textColor = [UIColor whiteColor];
        distanceLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:distanceLabel];
        
        timesLabel = [UILabel newAutoLayoutView];
        timesLabel.textColor = [UIColor whiteColor];
        timesLabel.numberOfLines = 0;
        timesLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:timesLabel];
        
        separator = [UIView newAutoLayoutView];
        separator.backgroundColor = [UIColor whiteColor];
        separator.alpha = .5f;
        [self.contentView addSubview:separator];

    }
    
    return self;
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
