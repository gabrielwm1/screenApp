//
//  AddButton.m
//  ButtonTest
//
//  Created by Mason Wolters on 11/19/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "AddButton.h"

@implementation AddButton

@synthesize tapGesture;

- (void)tap {
    if (isCheck) {
        [self animateToPlus];
    } else {
        [self animateToCheck];
    }
    
    isCheck = !isCheck;
}

- (void)animateToCheck {
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        [self goToCheck];
    }completion:nil];
}

- (void)animateToPlus {
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        horizontalBar.transform = CGAffineTransformMakeRotation(0);
        horizontalBar.frame = CGRectMake(0, 0, self.frame.size.width, self.lineWidth);
        horizontalBar.center = [self center];
        verticalBar.transform = CGAffineTransformIdentity;
        verticalBar.frame = CGRectMake(0, 0, self.lineWidth, self.frame.size.height);
        verticalBar.center = [self center];
        
        horizontalBar.backgroundColor = self.plusColor;
        verticalBar.backgroundColor = self.plusColor;
    }completion:nil];
}

- (void)goToCheck {
    NSLog(@"go to check does bar exist: %@", (horizontalBar)?@"YES":@"NO");
    loadAsChecked = YES;
    float shortHeight = .3;
    float shortWidth = .5;
    
    float topX = 1;
    float bottomX = .5;
    
    float extraWidth = horizontalBar.frame.size.height;
    
    horizontalBar.frame = CGRectMake(0, 0, sqrtf((self.frame.size.height*shortHeight)*(self.frame.size.height*shortHeight)
                                                 +(self.frame.size.width*shortWidth)*(self.frame.size.width*shortWidth))+extraWidth, self.checkWidth);
    horizontalBar.transform = CGAffineTransformMakeRotation(atanf(shortHeight/shortWidth));
    horizontalBar.center = CGPointMake((shortWidth/2)*self.frame.size.width, self.frame.size.height - (shortHeight/2)*self.frame.size.height);
    
    float verticalBarHeight = sqrt(self.frame.size.height*self.frame.size.height+self.frame.size.width*(topX-bottomX)*(topX-bottomX)*self.frame.size.width)+extraWidth;
    verticalBar.frame = CGRectMake(0, 0, self.checkWidth, verticalBarHeight);
    verticalBar.transform = CGAffineTransformMakeRotation(atanf(bottomX/topX));
    verticalBar.center = CGPointMake(self.frame.size.height*bottomX+self.frame.size.height*(bottomX/2), self.frame.size.height/2);
    
    horizontalBar.backgroundColor = self.checkColor;
    verticalBar.backgroundColor = self.checkColor;
}

- (CGPoint)center {
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!horizontalBar) {
        horizontalBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.lineWidth)];
        horizontalBar.backgroundColor = self.plusColor;
        horizontalBar.layer.cornerRadius = horizontalBar.frame.size.height/2;
        horizontalBar.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:horizontalBar];
        
        verticalBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.lineWidth, self.frame.size.height)];
        verticalBar.backgroundColor = self.plusColor;
        verticalBar.layer.cornerRadius = verticalBar.frame.size.width/2;
        verticalBar.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:verticalBar];
        
        if (loadAsChecked) {
            [self goToCheck];
        }
        
    }
    
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.plusColor = [UIColor blackColor];
        self.checkColor = [UIColor greenColor];
        self.lineWidth = 2.0f;
        tapGesture = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:tapGesture];
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
