//
//  MovieStatusButton.h
//  Screen
//
//  Created by Mason Wolters on 1/9/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum MovieStatus {
    movieOnWatchlist,
    movieSeen,
    movieAdd,
    statusLoading,
    statusSuccess
}MovieStatus;

@interface MovieStatusButton : UIView

@property (nonatomic) MovieStatus status;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)animateToStatus:(MovieStatus)status;
- (void)goToFailForDuration:(float)duration;

@end
