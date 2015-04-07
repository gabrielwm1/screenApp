//
//  FriendRequestButton.h
//  Screen
//
//  Created by Mason Wolters on 11/17/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

typedef enum ButtonType{
    buttonTypeAdd,
    buttonTypeFriends,
    buttonTypeWaiting,
    buttonTypeRequested
}ButtonType;

@protocol FriendRequestButtonDelegate <NSObject>

- (void)friendRequestButton:(id)button changedTypeTo:(ButtonType)type;

@end

@interface FriendRequestButton : UIView {
    UIImageView *imageView;
    UILabel *label;
}

@property (nonatomic) ButtonType buttonType;
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) NSObject<FriendRequestButtonDelegate> *delegate;
@property (nonatomic) int index;

- (void)animateToWaiting;

@end

