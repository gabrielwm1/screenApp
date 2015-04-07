//
//  FriendTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 11/15/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FBProfilePictureView.h>
#import "Constants.h"
#import "ProfilePictureView.h"
#import "FriendRequestButton.h"

@interface FriendTableViewCell : UITableViewCell {
    UIView *selectionBackground;
}

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet ProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet FriendRequestButton *friendRequestButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *friendRequestButtonWidth;

@property (nonatomic) ButtonType buttonType;

@end
