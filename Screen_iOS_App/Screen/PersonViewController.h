//
//  PersonViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/13/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WatchlistTableViewCell.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import "TMDBHelper.h"
#import "MovieViewController.h"
#import "MovieSearchTableViewCell.h"

@interface PersonViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MovieSearchCellDelegate> {
    TMDBPerson *fullPerson;
    TMDBMovie *selectedMovie;
    
    NSArray *sortedAsCast;
    NSArray *sortedAsCrew;
    
    BOOL canShowWatchlist;
    BOOL canShowSeen;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) TMDBPerson *person;
@property (strong, nonatomic) TMDBCrew *director;
@property (strong, nonatomic) MarqueeLabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@end
