//
//  TheaterViewController.h
//  Screen
//
//  Created by Mason Wolters on 12/4/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnConnectHelper.h"
#import "GooglePlacesHelper.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import <UIImageView+WebCache.h>
#import <EDStarRating/EDStarRating.h>
#import "Constants.h"
#import "UIImage+Color.h"
#import "TheaterShowtimeTableViewCell.h"
#import <MapKit/MapKit.h>
#import "TMDBHelper.h"

@class HMSegmentedControl;

@interface TheaterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    MarqueeLabel *titleLabel;
    GPPlace *theaterPlace;
    NSArray *showtimes;
    NSArray *allShowtimes;
    BOOL viewHasAppeared;
    NSDateFormatter *dateFormatter;
    TMDBMovie *selectedMovie;
    OCMovie *selectedOcMovie;
}

@property (strong, nonatomic) OCTheater *theater;
@property (strong, nonatomic) OCMovie *highlightMovie;
@property (strong, nonatomic) IBOutlet EDStarRating *starRating;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) IBOutlet HMSegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIButton *phoneButton;

@end
