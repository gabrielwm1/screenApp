//
//  FriendRequestButton.m
//  Screen
//
//  Created by Mason Wolters on 11/17/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "FriendRequestButton.h"

@implementation FriendRequestButton

const int addButtonColor = 0x2b3844;
const int greenButtonColor = 0x60b050;
const int grayButtonColor = 0x656565;

@synthesize buttonType = _buttonType;
@synthesize widthConstraint;
@synthesize delegate;

- (void)tap {
    if (_buttonType == buttonTypeAdd) {
        [self animateToWaiting];
        if ([delegate respondsToSelector:@selector(friendRequestButton:changedTypeTo:)]) {
            [delegate friendRequestButton:self changedTypeTo:buttonTypeWaiting];
        }
    } else if (_buttonType == buttonTypeRequested) {
        [self animateToFriends];
        if ([delegate respondsToSelector:@selector(friendRequestButton:changedTypeTo:)]) {
            [delegate friendRequestButton:self changedTypeTo:buttonTypeFriends];
        }
    }
}

- (void)animateToWaiting {
    self.widthConstraint.constant = 60.0f;
    [self setNeedsUpdateConstraints];
    

    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        [self layoutIfNeeded];
        self.buttonType = buttonTypeWaiting;
    }completion:nil];
}

- (void)animateToFriends {
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        self.buttonType = buttonTypeFriends;
    }completion:nil];
}

- (void)setButtonType:(ButtonType)buttonType {
    _buttonType = buttonType;
    
    self.widthConstraint.constant = (buttonType == buttonTypeAdd)?30.0f:60.0f;
    
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
    }
    
    if (!label) {
        label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
        [self addSubview:label];
    }
    
    if (buttonType == buttonTypeAdd) {
        self.backgroundColor = UIColorFromRGB(addButtonColor);
        label.frame = CGRectMake(self.frame.size.width, 0, 80, self.frame.size.height);
        label.text = @"";
        imageView.image = [UIImage imageNamed:@"add_small"];
        imageView.frame = CGRectMake(0, 0, 13.0f, 13.0f);
        imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    } else if (buttonType == buttonTypeFriends) {
        self.backgroundColor = UIColorFromRGB(greenButtonColor);
        label.frame = CGRectMake(22, 0, self.frame.size.width - 22, self.frame.size.height);
        label.text = @"Friends";
        imageView.image = [UIImage imageNamed:@"checkmark_small"];
        imageView.frame = CGRectMake(0, 0, 13.0f, 13.0f);
        imageView.center = CGPointMake(11.0f, self.frame.size.height/2);
    } else if (buttonType == buttonTypeWaiting) {
        self.backgroundColor = UIColorFromRGB(grayButtonColor);
        label.frame = CGRectMake(22, 0, self.frame.size.width - 22, self.frame.size.height);
        label.text = @"Waiting";
        imageView.image = [UIImage imageNamed:@"clock_small"];
        imageView.frame = CGRectMake(0, 0, 13.0f, 13.0f);
        imageView.center = CGPointMake(11.0f, self.frame.size.height/2);
    } else if (buttonType == buttonTypeRequested) {
        self.backgroundColor = UIColorFromRGB(blueColor);
        label.frame = CGRectMake(22, 0, self.frame.size.width - 22, self.frame.size.height);
        label.text = @"Confirm";
        imageView.image = [UIImage imageNamed:@"add_small"];
        imageView.frame = CGRectMake(0, 0, 13.0f, 13.0f);
        imageView.center = CGPointMake(11.0f, self.frame.size.height/2);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.backgroundColor = UIColorFromRGB(addButtonColor);
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    
    self.buttonType = self.buttonType;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
