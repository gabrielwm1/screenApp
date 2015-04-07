//
//  FirstViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/6/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContinuousTableView.h"

@class MarqueeLabel;
@class RTMovie;
@class MovieTableViewCell;

typedef enum MoviesSortType{
    nowPlaying,
    boxOffice,
    opening
}MoviesSortType;

@interface MoviesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ContinuousTableViewDelegate> {
    NSArray *movies;
    RTMovie *selectedMovie;
    MoviesSortType sortType;
    
    int totalPagesForNowPlaying;
    
    NSArray *nowPlayingMovies;
    NSArray *boxOfficeMovies;
    NSArray *openingMovies;
}

@property (strong, nonatomic) IBOutlet ContinuousTableView *tableView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) MarqueeLabel *titleLabel;

@end

