//
//  Tomatometer.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "Tomatometer.h"

@implementation Tomatometer

const int redTomato = 0xdd5e01;
const int greenTomato = 0x9ecc52;

@synthesize percentage = _percentage;

- (void)setPercentage:(float)percentage {
    _percentage = percentage;
    if (_percentage < 0) {
        _percentage = 0;
    }
    if (_percentage > 1) {
        _percentage = 1;
    }
    
    redView.frame = CGRectMake(0, 0, self.bounds.size.width * _percentage, self.bounds.size.height);
//    [self setNeedsDisplay];
}

//- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(context, UIColorFromRGB(greenTomato).CGColor);
//    CGContextFillRect(context, rect);
//    
//    CGRect greenRect = CGRectMake(0, 0, rect.size.width * _percentage, rect.size.height);
//    CGContextSetFillColorWithColor(context, UIColorFromRGB(redColor).CGColor);
//    CGContextFillRect(context, greenRect);
//}

- (void)layoutSubviews {
    self.layer.cornerRadius = 2.5f;
    self.layer.masksToBounds = YES;
    
    redView.frame = CGRectMake(0, 0, self.bounds.size.width * _percentage, self.bounds.size.height);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        NSLog(@"init tomatometer");
        
        self.backgroundColor = UIColorFromRGB(greenTomato);
        
        redView = [[UIView alloc] initWithFrame:self.bounds];
        redView.backgroundColor = UIColorFromRGB(redTomato);
        [self addSubview:redView];
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
