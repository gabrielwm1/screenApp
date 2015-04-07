//
//  MovieStatusButton.m
//  Screen
//
//  Created by Mason Wolters on 1/9/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "MovieStatusButton.h"
#import "Constants.h"

@implementation MovieStatusButton

const int addColor = 0x2b3844;
const int green = 0x60b050;
const int gray = 0x656565;
const int orange = 0xdd5e01;

@synthesize status = _status;
@synthesize imageView;
@synthesize activityIndicator;

- (void)awakeFromNib {
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 13)];
    [self addSubview:imageView];
    
}

- (void)goToFailForDuration:(float)duration {
    [activityIndicator removeFromSuperview];
    imageView.image = [UIImage imageNamed:@"add_small"];
    [UIView animateWithDuration:.3f animations:^{
        imageView.transform = CGAffineTransformMakeRotation(45.0f/180.0f * M_PI);
        self.backgroundColor = UIColorFromRGB(0x880000);
    }];
    [self performSelector:@selector(undoFail) withObject:nil afterDelay:duration];
}

- (void)undoFail {
    imageView.transform = CGAffineTransformIdentity;
    self.status = movieAdd;
}

- (void)animateToStatus:(MovieStatus)status {
    _status = status;
    
    [UIView animateWithDuration:.3f animations:^{
        self.status = status;
    }];
}

- (void)setStatus:(MovieStatus)status {
    _status = status;
    
    [activityIndicator removeFromSuperview];
    
    if (status == movieOnWatchlist) {
        imageView.image = [UIImage imageNamed:@"watchlist"];
        self.backgroundColor = UIColorFromRGB(green);
    } else if (status == movieSeen) {
        imageView.image = [UIImage imageNamed:@"seen"];
        self.backgroundColor = UIColorFromRGB(orange);
//        self.backgroundColor = UIColorFromRGB(green);
    } else if (status == movieAdd) {
        //Show Add Button
        
        self.backgroundColor = UIColorFromRGB(addColor);
        imageView.image = [UIImage imageNamed:@"add_small"];
    } else if (status == statusLoading) {
        imageView.image = [UIImage new];
        
        if (!activityIndicator) {
            activityIndicator = [[UIActivityIndicatorView alloc] init];
            activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        }
        [activityIndicator startAnimating];
        [self addSubview:activityIndicator];
    } else if (status == statusSuccess) {
        imageView.image = [UIImage imageNamed:@"checkmark_small"];
        self.backgroundColor = UIColorFromRGB(green);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSLog(@"layout subviews status button");
    imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
