//
//  FriendsViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/15/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MarqueeLabel/MarqueeLabel.h>
#import "FriendTableViewCell.h"
#import "ParseHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <TwitterKit/TwitterKit.h>
#import "PFActionButton.h"
#import "PFColor.h"
#import "PFImage.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "FriendsSearchBar.h"
#import "SearchFriendsViewController.h"
#import <STPTransitions/STPTransitions.h>
#import "ProfileNavButton.h"

@interface FriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FriendsSearchBarDelegate, FriendRequestButtonDelegate, ProfileNavButtonDelegate, SearchFriendsViewControllerDelegate> {
    MarqueeLabel *titleLabel;
    NSArray *friendRequests;
    NSArray *parseFriends;
    NSArray *facebookFriends;
    NSArray *twitterFriends;
    NSDictionary<FBGraphUser> *selectedFriend;
    PFUser *selectedUser;
    
    PFActionButton *facebookButton;
    PFActionButton *twitterButton;
    
    int layoutCount;
    BOOL showFacebookButton;
    BOOL showTwitterButton;
}

@property (strong, nonatomic) IBOutlet UIView *facebookView;
@property (strong, nonatomic) IBOutlet UIView *twitterView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopSpaceConstraint;
@property (strong, nonatomic) IBOutlet FriendsSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *facebookHorizontalConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *twitterHorizontalConstraint;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@end
