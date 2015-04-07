//
//  DemandBarView.m
//  Screen
//
//  Created by Mason Wolters on 11/14/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "DemandBarView.h"

@implementation DemandBarView

@synthesize imageView;
@synthesize percentage = _percentage;

- (void)setPercentage:(float)percentage {
    _percentage = percentage;
    
    if (_percentage < 0) {
        _percentage = 0;
    }
    if (_percentage > 1) {
        _percentage = 1;
    }
    if (isnan(_percentage)) {
        _percentage = 0;
    }
    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, frame.size.width * _percentage, self.frame.size.height)];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, frame.size.width * _percentage, self.frame.size.height) cornerRadius:self.layer.cornerRadius];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.imageView.layer.mask = mask;
}

//- (void)drawRect:(CGRect)rect {
//    imageView.frame = rect;
//    frame = rect;
//    [self setPercentage:self.percentage];
//}

- (void)layoutSubviews {
    NSLog(@"layout subviews");
    [super layoutSubviews];
//    imageView.frame = self.bounds;
    frame = self.bounds;
    self.percentage = self.percentage;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    
//    imageView.frame = self.bounds;
//    frame = self.bounds;
//    [self setPercentage:self.percentage];
//}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        image = [UIImage imageNamed:@"demandBar"];
        
        imageView = [[UIImageView alloc] init];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        imageView.image = image;
        [self addSubview:imageView];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        
//        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        imageView.image = image;
//        [self addSubview:imageView];
        
        self.layer.cornerRadius = 2.5f;
        self.layer.masksToBounds = YES;
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
