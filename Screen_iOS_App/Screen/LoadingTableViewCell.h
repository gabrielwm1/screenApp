//
//  LoadingTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 12/18/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HandlerBlock)(void);

@interface RetryButton : UIView {
    BOOL didUpdateConstraints;
}

@property (strong, nonatomic) UILabel *retryLabel;
@property (strong, nonatomic) UIImageView *retryImage;
@property (strong, nonatomic) UIView *containerView;

- (void)addTarget:(id)target selector:(SEL)selector;

@end

@interface ErrorImage : UIView

@property (strong, nonatomic) UIImageView *redImage;
@property (strong, nonatomic) UIImageView *whiteImage;

- (void)animateToRedImageWithDuration:(float)duration;

@end

@interface LoadingTableViewCell : UITableViewCell

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) ErrorImage *errorImage;
@property (strong, nonatomic) RetryButton *retryButton;
@property (strong, nonatomic) HandlerBlock retryHandler;

- (void)start;
- (void)goToErrorRetry;
- (void)goToRetryUnanimated;

@end
