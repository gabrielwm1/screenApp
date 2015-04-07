//
//  SearchFriendsViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/16/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendTableViewCell.h"
#import "FriendsSearchBar.h"
#import <STPTransitions/STPTransitions.h>
#import "ParseHelper.h"

@protocol SearchFriendsViewControllerDelegate <NSObject>

- (void)selectedUser:(PFUser *)user;

@end

@interface SearchFriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FriendsSearchBarDelegate, FriendRequestButtonDelegate> {
    NSArray *users;
    PFUser *selectedUser;
}

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet FriendsSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSObject<SearchFriendsViewControllerDelegate> *delegate;

- (void)finishIntro;
- (void)animateInWithDuration:(float)duration;

@end
