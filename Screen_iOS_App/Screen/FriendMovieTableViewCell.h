//
//  FriendMovieTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 12/3/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfilePictureView.h"
#import "ParseHelper.h"
#import "Constants.h"

@class EDStarRating;

typedef void(^BlankBlock)(void);

@protocol FriendMovieCellDelegate <NSObject>

- (void)tappedInviteForUser:(PFUser *)user stopActivityIndicator:(BlankBlock)stopAnimating;

@end

@interface FriendMovieTableViewCell : UITableViewCell {
    UIView *selectionBackground;
    BOOL didUpdateConstraints;
    NSString *identifier;
}

@property (strong, nonatomic) IBOutlet ProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) UIView *separator;
@property (strong, nonatomic) IBOutlet EDStarRating *starRating;
@property (strong, nonatomic) UIView *inviteButton;
@property (strong, nonatomic) UILabel *inviteLabel;
@property (strong, nonatomic) UIImageView *watchlistIcon;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) NSObject<FriendMovieCellDelegate> *delegate;

@end
