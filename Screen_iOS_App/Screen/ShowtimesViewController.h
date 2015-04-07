//
//  ShowtimesViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GooglePlacesHelper.h"
#import "LocationHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import <TwitterKit/TwitterKit.h>
#import "StringNormalizer.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import "WatchlistTableViewCell.h"
#import "OnConnectHelper.h"
#import "MovieViewController.h"
#import "TheaterTableViewCell.h"
#import "LocationPickerViewController.h"
#import "NowPlayingTableViewCell.h"

typedef enum SortShowtimesType {
    byMovie,
    byTheater,
    byTrending
} SortShowtimesType ;

@interface ShowtimesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TheaterCellDelegate, LocationPickerDelegate, NowPlayingCellDelegate> {
    MarqueeLabel *titleLabel;
    NSArray *playingNearby;
    NSArray *playingOnWatchlist;
    TMDBMovie *selectedMovie;
    OCMovie *selectedOCMovie;
    NSArray *mostPopular;
    NSMutableArray *loadedSections;
    NSMutableArray *erroredSections;
    NSArray *theaters;
    OCTheater *selectedTheater;
    PFMovie *selectedPFMovie;
    BOOL doneLoadingTheaters;
    NSMutableDictionary *showtimesForTheaters;
    OCMovie *selectedMovieTheater;
    BOOL viewHasAppeared;
    NSMutableArray *movieHeaders;
    NSMutableArray *pastHeaders;
    BOOL justAddedMovie;
    int scrollCount;
    UILabel *locationLabel;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *radiusView;
//@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@end
