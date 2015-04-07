//
//  WatchlistsViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WatchlistTableViewCell.h"
#import "ParseHelper.h"
#import "Constants.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import "MovieViewController.h"
#import <STPTransitions/STPTransition.h>
#import "LocationHelper.h"
#import "ScreenLogInViewController.h"
#import <ParseUI/ParseUI.h>
#import <PureLayout/PureLayout.h>
#import <AVFoundation/AVFoundation.h>
#import "FriendPictureViewController.h"

typedef enum WatchlistType {
    watchlist,
    seen
} WatchlistType;

@interface WatchlistsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FriendPictureViewControllerDelegate> {
    TMDBMovie *selectedMovie;
    PFMovie *selectedPFMovie;
    int mostDemand;
    
    UITableViewHeaderFooterView *seenHeader;
    BOOL pastSeenHeader;
    BOOL canShowWatchlist;
    BOOL canShowSeen;
    
    BOOL hasLoadedWatchlist;
    AVPlayerLayer *movieLayer;
    AVPlayer *moviePlayer;
    UIView *cancelMovieView;
    ProfilePictureView *profilePicture;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSArray *seenMovies;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) MarqueeLabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (strong, nonatomic) PFUser *friendViewing;

- (void)gotoMovie:(TMDBMovie *)movie;
- (void)showLogin;
- (void)playVideo;

@end
