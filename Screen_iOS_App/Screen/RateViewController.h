//
//  RateViewController.h
//  Screen
//
//  Created by Mason Wolters on 12/19/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EDStarRating/EDStarRating.h>

@protocol RateDelegate <NSObject>

- (void)didRate:(float)rating;

@optional;

- (void)refuseRating;

@end


@interface RateViewController : UIViewController <EDStarRatingProtocol> {
    UIView *backgroundView;
    UIView *innerView;
    UIView *innerBackground;
}

- (void)animateInCompletion:(void(^)(BOOL finished))completion origin:(CGPoint)origin;

@property (weak, nonatomic) NSObject<RateDelegate> *delegate;

@property (strong, nonatomic) NSString *movieTitle;

@property (strong, nonatomic) UIView *snapshotView;

@end
