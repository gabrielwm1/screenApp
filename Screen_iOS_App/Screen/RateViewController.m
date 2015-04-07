//
//  RateViewController.m
//  Screen
//
//  Created by Mason Wolters on 12/19/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "RateViewController.h"
#import "Constants.h"
#import <STPTransitions/STPTransitions.h>
#import "Constants.h"
#import "UIImage+Color.h"

@interface RateViewController () {
    EDStarRating *starRating;
    UITextView *textView;
}

@end

@implementation RateViewController

@synthesize delegate;
@synthesize movieTitle = _movieTitle;
@synthesize snapshotView;

- (void)setMovieTitle:(NSString *)movieTitle {
    _movieTitle = movieTitle;
    
//    if (movieTitle && ![movieTitle isEqualToString:@""]) {
//        textView.text = [NSString stringWithFormat:@"Please rate \"%@\" to help your friends discover new movies.", movieTitle];
//    } else {
        textView.text = @"Rate this movie";
//    }
}

- (void)animateInCompletion:(void (^)(BOOL))completion origin:(CGPoint)origin {
    snapshotView.alpha = 0.0f;
//    [self.view addSubview:snapshotView];
    
    innerView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(.5, .5), CGAffineTransformMakeTranslation(origin.x - self.view.center.x, origin.y - self.view.center.y));
    innerView.alpha = 0.0f;
    innerBackground.alpha = 0.0f;
    [UIView animateWithDuration:.5f delay:0.0f usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        backgroundView.alpha = .5f;
        innerView.transform = CGAffineTransformIdentity;
        innerView.alpha = 1.0f;
        innerBackground.alpha = .9f;
        snapshotView.alpha = 1.0f;
    }completion:completion];
}

- (void)tapView {
    self.transitioningDelegate = [STPTransitionCenter sharedInstance];
    
    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void(^executeOnComplete)(BOOL finished) ) {
        [UIView animateWithDuration:.2f animations:^{
            self.view.alpha = 0.0f;
        } completion:executeOnComplete ];
    }];
    
    [self dismissViewControllerUsingTransition:transition onCompletion:nil];
}

- (void)nopePress {
    if (delegate && [delegate respondsToSelector:@selector(refuseRating)]) {
        [delegate refuseRating];
    }
    
    [self tapView];
}

- (void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating {
    if (delegate && [delegate respondsToSelector:@selector(didRate:)]) {
        [delegate didRate:rating];
    }
    
    [self tapView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    
    backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.0f;
    [backgroundView addGestureRecognizer:tap];
    [self.view addSubview:backgroundView];
    
    innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 50, 100)];
    innerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 - 100);
    innerView.backgroundColor = [UIColor clearColor];
    innerView.layer.cornerRadius = 5.0f;
    [self.view addSubview:innerView];
    
    innerBackground = [[UIView alloc] initWithFrame:innerView.bounds];
    innerBackground.backgroundColor = UIColorFromRGB(grayColor);
    innerBackground.layer.cornerRadius = 5.0f;
    [innerView addSubview:innerBackground];
    
    textView = [[UITextView alloc] initWithFrame:CGRectInset(innerView.bounds, 20, 10)];
    textView.textColor = [UIColor whiteColor];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.editable = NO;
    textView.selectable = NO;
    textView.backgroundColor = [UIColor clearColor];
    [self setMovieTitle:self.movieTitle];
//    [innerView addSubview:textView];
    
    starRating = [[EDStarRating alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
    starRating.center = CGPointMake(innerView.frame.size.width/2, 50);
    starRating.backgroundColor = [UIColor clearColor];
    starRating.starImage = [[UIImage imageNamed:@"star"] imageWithColor:UIColorFromRGB(0xffa200)];
    starRating.starHighlightedImage = [[UIImage imageNamed:@"star_full"] imageWithColor:UIColorFromRGB(0xffa200)];
    starRating.maxRating = 5.0;
    starRating.delegate = self;
    starRating.horizontalMargin = 12;
    starRating.editable=YES;
    starRating.rating= 0.0;
    starRating.displayMode = EDStarRatingDisplayHalf;
    [innerView addSubview:starRating];
    
    UIButton *nopeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, innerView.frame.size.width, 40)];
    nopeButton.center = CGPointMake(innerView.frame.size.width/2, innerView.frame.size.height - 25);
    [nopeButton setTitle:@"No Thanks" forState:UIControlStateNormal];
    [nopeButton setTitleColor:UIColorFromRGB(blueColor) forState:UIControlStateNormal];
    [nopeButton setTitleColor:[UIColorFromRGB(blueColor) colorWithAlphaComponent:.5f] forState:UIControlStateHighlighted];
    [nopeButton addTarget:self action:@selector(nopePress) forControlEvents:UIControlEventTouchUpInside];
//    [innerView addSubview:nopeButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
