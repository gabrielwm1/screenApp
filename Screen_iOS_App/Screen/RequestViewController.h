//
//  RequestViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/14/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STPTransitions/STPTransitions.h>

@interface RequestViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
    UIView *backgroundView;
    UIView *innerView;
    UIView *typingView;
    UIView *successView;
    UIButton *sendButton;
}

@property (strong, nonatomic) NSString *passedTitle;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)animateInCompletion:(void(^)(BOOL finished))completion origin:(CGPoint)origin;

@end
