//
//  SearchSegue.m
//  Screen
//
//  Created by Mason Wolters on 11/7/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "SearchSegue.h"
#import "WatchlistsViewController.h"
#import "MovieSearchViewController.h"
#import <STPTransitions.h>

@implementation SearchSegue

- (void)perform {
    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void (^executeOnCompletion)(BOOL finished)) {
        [containerView addSubview:toView];
//        [(MovieSearchViewController*)[[(UINavigationController*)self.destinationViewController viewControllers] objectAtIndex:0] animateInOnCompletion:^(BOOL finished) {
//            executeOnCompletion(YES);
//        }];
        [(MovieSearchViewController*)self.destinationViewController animateInOnCompletion:^(BOOL finished) {
            executeOnCompletion(YES);
        }];

    }];
    
    NSLog(@"source: %@", self.sourceViewController);
    
//    [(UIViewController*)self.sourceViewController setTransitioningDelegate:[STPTransitionCenter sharedInstance]];
    NSLog(@"nav contoller: %@", [self.sourceViewController navigationController]);
    [[self.sourceViewController navigationController] setDelegate:[STPTransitionCenter sharedInstance]];
    [[(WatchlistsViewController *)self.sourceViewController navigationController] setTransitioningDelegate:[STPTransitionCenter sharedInstance]];

    [[(UIViewController *)self.sourceViewController navigationController] pushViewController:self.destinationViewController usingTransition:transition];
//    [[(UIViewController *)self.sourceViewController navigationController] pushViewController:self.destinationViewController animated:YES];
//    [self.sourceViewController presentViewController:self.destinationViewController usingTransition:transition onCompletion:nil];
//    [self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:nil];
}

@end
