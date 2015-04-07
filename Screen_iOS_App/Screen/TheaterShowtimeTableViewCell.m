//
//  TheaterShowtimeTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 12/4/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TheaterShowtimeTableViewCell.h"
#import <PureLayout/PureLayout.h>

@implementation TheaterShowtimeTableViewCell

@synthesize imageView;
@synthesize titleLabel;
@synthesize timesLabel;

- (void)awakeFromNib {
    // Initialization code
    self.timesLabel.textColor = UIColorFromRGB(blueColor);
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
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

- (void)updateConstraints {
    if (!didUpdateConstraints) {
         self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        
//        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
//            [self.imageView autoSetDimension:ALDimensionHeight toSize:45.0f];
//            [self.imageView autoSetDimension:ALDimensionWidth toSize:30.0f];
//            [self.imageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:4.0f relation:NSLayoutRelationGreaterThanOrEqual];
//        }];
//        [self.imageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView withOffset:4.0f];
//        [self.imageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:8.0f];
//        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        
//        
//        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
//            [imageView autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
//        }];
//        [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//        [titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:imageView withOffset:8.0f];
//        [titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView withOffset:8.0f];
//        [titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:8.0f];
//        
//        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
//            [timesLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
//        }];
//        [timesLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel withOffset:6.0f];
//        [timesLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:imageView withOffset:8.0f];
//        [timesLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:8.0f];
//        [timesLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:-8.0f];
//        [timesLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[imageView(30)]-8-[titleLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView, titleLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[imageView(30)]-8-[timesLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView, timesLabel)]];
                
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[titleLabel]-8-[timesLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel, timesLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[imageView(45)]->=4-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        
        didUpdateConstraints = YES;
    }
    
    [super updateConstraints];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        imageView = [UIImageView newAutoLayoutView];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        
        titleLabel = [UILabel newAutoLayoutView];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [self.contentView addSubview:titleLabel];
        
        timesLabel = [UILabel newAutoLayoutView];
        timesLabel.numberOfLines = 0;
        timesLabel.textColor = UIColorFromRGB(blueColor);
        timesLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:timesLabel];
        
        [self updateConstraints];
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
