//
//  WatchlistTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "PFMovie.h"
#import "TMDBHelper.h"
#import "Tomatometer.h"
#import "DemandBarView.h"
#import "MovieStatusButton.h"

@class EDStarRating;

@interface WatchlistTableViewCell : UITableViewCell {
    UIView *selectionBackground;
    CAGradientLayer *maskLayer;
}
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) SortType sortType;
@property (strong, nonatomic) PFMovie *movie;

@property (strong, nonatomic) IBOutlet Tomatometer *tomatometer;
@property (strong, nonatomic) IBOutlet UILabel *tomatometerLabel;
@property (strong, nonatomic) IBOutlet UILabel *releaseLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *demandLabel;
@property (strong, nonatomic) IBOutlet DemandBarView *demandBarView;
@property (strong, nonatomic) IBOutlet MovieStatusButton *statusButton;
@property (nonatomic) int mostDemand;
@property (strong, nonatomic) IBOutlet EDStarRating *starRating;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *starRatingWidth;

@property (nonatomic) float sideInset;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;

- (void)setImageURL:(NSURL *)url;
- (void)animateDemandBarIn;
- (void)animateTomatometerIn;
- (void)setRating:(NSNumber *)rating;

@end
