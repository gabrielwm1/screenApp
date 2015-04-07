//
//  FriendsSegue.m
//  Screen
//
//  Created by Mason Wolters on 1/12/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "FriendsSegue.h"
#import <STPTransitions/STPTransitions.h>

@implementation FriendsSegue

- (void)perform {
    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void(^executeOnCompletion)(BOOL finished)) {
        
        toView.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        toView.alpha = 0.0f;
        [containerView addSubview:toView];
        
        [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toView.transform = CGAffineTransformIdentity;
            toView.alpha = 1.0f;
            fromView.transform = CGAffineTransformMakeScale(.7f, .7f);
            fromView.alpha = 0.0f;
        }completion:executeOnCompletion];
    }];
    [[self.sourceViewController navigationController] setTransitioningDelegate:[STPTransitionCenter sharedInstance]];
    [[self.sourceViewController navigationController] setDelegate:[STPTransitionCenter sharedInstance]];
    
    [[self.sourceViewController navigationController] pushViewController:self.destinationViewController usingTransition:transition];
}

@end
