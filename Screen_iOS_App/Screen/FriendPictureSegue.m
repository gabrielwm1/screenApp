//
//  FriendPictureSegue.m
//  Screen
//
//  Created by Mason Wolters on 2/18/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "FriendPictureSegue.h"
#import <STPTransitions/STPTransitions.h>
#import "FriendPictureViewController.h"

@implementation FriendPictureSegue

- (void)perform {
    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void (^executeOnCompletion)(BOOL finished)) {
        [containerView addSubview:toView];
        //        [(MovieSearchViewController*)[[(UINavigationController*)self.destinationViewController viewControllers] objectAtIndex:0] animateInOnCompletion:^(BOOL finished) {
        //            executeOnCompletion(YES);
        //        }];
        [(FriendPictureViewController *)self.destinationViewController animateForward:YES onCompletion:executeOnCompletion];
        
    }];
    
    NSLog(@"source: %@", self.sourceViewController);
    
    //    [(UIViewController*)self.sourceViewController setTransitioningDelegate:[STPTransitionCenter sharedInstance]];
    NSLog(@"nav contoller: %@", [self.sourceViewController navigationController]);
    [self.sourceViewController setTransitioningDelegate:[STPTransitionCenter sharedInstance]];
//    [[self.sourceViewController navigationController] setDelegate:[STPTransitionCenter sharedInstance]];
//    [[self.sourceViewController navigationController] setTransitioningDelegate:[STPTransitionCenter sharedInstance]];
    [self.sourceViewController presentViewController:self.destinationViewController usingTransition:transition onCompletion:nil];
//    [[(UIViewController *)self.sourceViewController navigationController] pushViewController:self.destinationViewController usingTransition:transition];
}

@end
