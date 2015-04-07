//
//  MovieSearchViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/7/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STPTransitions.h>
#import "RottenTomatoesHelper.h"
#import "MovieSearchTableViewCell.h"
#import "TMDBHelper.h"
#import "MovieViewController.h"
#import "ContinuousTableView.h"
#import "SearchBarView.h"
#import "ParseConverter.h"
#import "OnConnectHelper.h"
#import "PersonSearchTableViewCell.h"
#import "PersonViewController.h"
#import "RequestFilmView.h"
#import "RequestViewController.h"

typedef void(^CompletionBlock)(BOOL finished);

@interface MovieSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ContinuousTableViewDelegate, SearchBarDelegate, UIGestureRecognizerDelegate, MovieSearchCellDelegate> {
    NSArray *movies;
    NSArray *people;
    TMDBMovie *selectedMovie;
    TMDBPerson *selectedPerson;
    SearchBarView *searchBarView;
    UITapGestureRecognizer *tapViewGesture;
    RequestFilmView *requestFilmView;
    UIView *hideRequestButtonView;
    UITableViewHeaderFooterView *peopleHeader;
    
    BOOL canShowWatchlist;
    BOOL canShowSeen;
    BOOL canLoadMoreMovies;
    int currentLoadedPage;
}

@property (strong, nonatomic) IBOutlet ContinuousTableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

- (void)animateInOnCompletion:(CompletionBlock)complete;

@end
