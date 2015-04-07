//
//  MovieViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimilarMoviesView.h"
#import "RateViewController.h"
#import "LocationPickerViewController.h"
#import "FriendMovieTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import "VODTableViewCell.h"

@class Tomatometer;
@class TMDBMovie;
@class WatchlistButton;
@class RTMovie;
@class PFUser;
@class MarqueeLabel;
@class AddButton;
@class DemandBarView;
@class OCMovie;

typedef enum MovieSection{
    movieSectionRatings,
    movieSectionVOD,
    movieSectionShowtimes,
    movieSectionFriends,
    movieSectionSimilar
} MovieSection;

@interface MovieViewController : UIViewController <SimilarMoviesViewDelegate, UITableViewDataSource, UITableViewDelegate, RateDelegate, LocationPickerDelegate, FriendMovieCellDelegate, MFMessageComposeViewControllerDelegate, VODTableViewCellDelegate> {
    RTMovie *rtMovie;
    AddButton *addButton;
    UIBarButtonItem *rightButton;
    UIBarButtonItem *checkButton;
    BOOL canLoadSimilar;
    BOOL canShowTomatoes;
    BOOL movieIsPlaying;
    BOOL loadedShowtimes;
    NSArray *friendsSeen;
    NSArray *friendsWatching;
    NSArray *showtimes;
    NSArray *theaters;
    PFUser *selectedUser;
    NSDateFormatter *timeFormatter;
    OCOrganizedShowtime *selectedShowtime;
    UITableViewHeaderFooterView *showtimesHeader;
    DemandBarView *demandBar;
    Tomatometer *tomatometer;
    BOOL viewHasAppeared;
    BOOL haveAnimatedTomatometer;
    UITapGestureRecognizer *tapPoster;
    NSArray *vodAvailabilities;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *summaryTextView;
@property (strong, nonatomic) IBOutlet UILabel *yearLabel;
@property (strong, nonatomic) IBOutlet UILabel *directorLabel;
@property (strong, nonatomic) IBOutlet UILabel *runtimeLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *directorLabelHeight;
@property (strong, nonatomic) IBOutlet UIImageView *playImage;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MarqueeLabel *titleLabel;
@property (strong, nonatomic) TMDBMovie *movie;
@property (strong, nonatomic) PFMovie *pfMovie;
@property (strong, nonatomic) OCMovie *ocMovie;
@property (strong, nonatomic) RTMovie *rottenTomatoesMovie;

@property (strong, nonatomic) IBOutlet WatchlistButton *seenButton;
@property (strong, nonatomic) IBOutlet WatchlistButton *watchlistButton;
@property (nonatomic) BOOL changingRadius;

@end
