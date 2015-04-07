//
//  WatchlistButton.m
//  Screen
//
//  Created by Mason Wolters on 12/2/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "WatchlistButton.h"

@implementation WatchlistButton

- (void)animateToGreenStateWithTitle:(NSString *)title {
    [UIView animateWithDuration:.2f animations:^{
        self.backgroundColor = UIColorFromRGB(greenColor);
        [self setTitle:title forState:UIControlStateNormal];
    }];
}

- (void)animateToGrayStateWithTitle:(NSString *)title {
    [UIView animateWithDuration:.2f animations:^{
        self.backgroundColor = UIColorFromRGB(0x2b3844);
        [self setTitle:title forState:UIControlStateNormal];
    }];
}

- (void)awakeFromNib {
    [self setBackgroundColor:UIColorFromRGB(0x2b3844)];
    self.layer.cornerRadius = 5.0f;
    [self.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
