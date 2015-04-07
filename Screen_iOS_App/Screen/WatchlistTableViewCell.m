//
//  WatchlistTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "WatchlistTableViewCell.h"
#import "ParseHelper.h"
#import <EDStarRating/EDStarRating.h>
#import "UIImage+Color.h"

@implementation WatchlistTableViewCell

@synthesize imageView;
@synthesize titleLabel;
@synthesize sortType = _sortType;
@synthesize movie = _movie;
@synthesize mostDemand;
@synthesize sideInset = _sideInset;
@synthesize starRating;

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.demandBarView removeFromSuperview];
}

- (void)setSideInset:(float)sideInset {
    _sideInset = sideInset;
    self.trailingConstraint.constant = -_sideInset;
    self.leadingConstraint.constant = _sideInset;
}

- (void)animateDemandBarIn {
    if (_sortType == sortTypeDemand) {
        CGRect frame = self.demandBarView.frame;
        self.demandBarView.frame = CGRectMake(frame.origin.x, frame.origin.y, 0, frame.size.height);
        [UIView animateWithDuration:.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.demandBarView.frame = frame;
        }completion:nil];
    }
}

- (void)animateTomatometerIn {
    if (_sortType == sortTypeTomatoes) {
        float percentage = self.tomatometer.percentage;
        self.tomatometer.percentage = 0.0f;
//        [UIView animateWithDuration:.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.tomatometer.percentage = percentage;
//        }completion:nil];
//        
        [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:.8f initialSpringVelocity:.2f options:0 animations:^{
            self.tomatometer.percentage = percentage;
        }completion:nil];
    }
}

- (void)tapStatusButton {
    if (self.statusButton.status == movieAdd) {
        self.statusButton.status = statusLoading;
        [[ParseHelper sharedInstance] addMovieToWatchlist:[ParseConverter tmdbMovieForPFMovie:self.movie] success:^(id obj) {
            [self.statusButton animateToStatus:movieOnWatchlist];
        }error:^(NSError *error) {
            [self.statusButton goToFailForDuration:1.0];
        }];
    }
}

- (void)setMovie:(PFMovie *)movie {
    _movie = movie;
    
    self.titleLabel.text = [_movie displayTitle];
    if (movie.posterPath && ![movie.posterPath isEqualToString:@""]) {
        [imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"]];
        [imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
    } else {
        imageView.image = [UIImage imageNamed:@"blankPoster"];
    }
    
    if (_sortType == sortTypeRelease) {
        self.releaseLabel.text = [[TMDBHelper sharedInstance] yearForString:movie.releaseDate];
    } else if (_sortType == sortTypeLocation) {
        
    } else if (_sortType == sortTypeTomatoes) {
        if (_movie.rottenTomatoesScore && ![_movie.rottenTomatoesScore isEqualToString:@"-1"]) {
            self.tomatometer.percentage = [_movie.rottenTomatoesScore floatValue]/100;
            self.tomatometerLabel.text = [NSString stringWithFormat:@"%@%%", _movie.rottenTomatoesScore];
            self.tomatometer.alpha = 1.0f;
        } else {
            self.tomatometer.percentage = 0.0f;
            self.tomatometerLabel.text = @"N/A";
            self.tomatometer.alpha = 0.3f;
        }
    } else if (_sortType == sortTypeDemand) {
        self.demandLabel.text = [NSString stringWithFormat:@"%i", movie.userCount];
        self.demandBarView.percentage = (float)movie.userCount/(float)mostDemand;
    }
}

- (void)setRating:(NSNumber *)rating {
    if (rating) {
        starRating.alpha = 1.0f;
        self.starRatingWidth.constant = 60.0f;
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        starRating.rating = [rating floatValue];
    } else {
        starRating.alpha = 0.0f;
        self.starRatingWidth.constant = 0.0f;
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)setSortType:(SortType)sortType {
    _sortType = sortType;
}

- (void)setImageURL:(NSURL *)url {
    [imageView sd_setImageWithURL:url];
}

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    _sideInset = 0;
    
    UITapGestureRecognizer *tapStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStatusButton)];
    [self.statusButton addGestureRecognizer:tapStatus];
    
    if (starRating) {
        starRating.starImage = [[UIImage imageNamed:@"star-template-small"] imageWithColor:UIColorFromRGB(0xffa200)];
        starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template-small"] imageWithColor:UIColorFromRGB(0xffa200)];
        starRating.maxRating = 5.0;
        starRating.editable = NO;
        starRating.horizontalMargin = 0;
        starRating.editable=YES;
        starRating.rating= 0;
        starRating.backgroundColor = [UIColor clearColor];
        starRating.userInteractionEnabled = NO;
        starRating.displayMode = EDStarRatingDisplayHalf;
    }
}

- (UIView *)selectionBackground {
    if (!selectionBackground) {
        selectionBackground = [[UIView alloc] initWithFrame:self.contentView.bounds];
        selectionBackground.backgroundColor = UIColorFromRGB(cellSelectColor);
        selectionBackground.alpha = 0.0f;
        
        maskLayer = [CAGradientLayer layer];
        
        CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
        CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        
        maskLayer.colors = [NSArray arrayWithObjects:(__bridge id)outerColor,
                            (__bridge id)innerColor, (__bridge id)innerColor, (__bridge id)outerColor, nil];
        maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.1],
                               [NSNumber numberWithFloat:0.9],
                               [NSNumber numberWithFloat:1.0], nil];
        
        maskLayer.bounds = CGRectMake(0, 0,
                                      self.contentView.frame.size.width,
                                      self.contentView.frame.size.height);
        maskLayer.anchorPoint = CGPointZero;
        
        selectionBackground.layer.mask = maskLayer;

        
        [self.contentView insertSubview:selectionBackground atIndex:0];
    }
    
    selectionBackground.frame = self.contentView.bounds;
    maskLayer.bounds = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    return selectionBackground;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
//    [super setHighlighted:highlighted animated:animated];
    
    [[self selectionBackground] setAlpha:(highlighted)?1.0f:0.0f];
//    self.contentView.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
//    self.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (animated) {
        [UIView animateWithDuration:.2f animations:^{
            self.contentView.backgroundColor = (selected)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
        }];
    } else {
        self.contentView.backgroundColor = (selected)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    }
}

@end
