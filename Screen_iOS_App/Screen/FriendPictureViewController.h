//
//  FriendPictureViewController.h
//  Screen
//
//  Created by Mason Wolters on 2/18/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseHelper.h"
#import "ProfilePictureView.h"

@protocol FriendPictureViewControllerDelegate <NSObject>

- (void)dismissedFriendPictureViewController;

@end

@interface FriendPictureViewController : UIViewController {
    
}

@property (nonatomic) CGRect startingPictureRect;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) ProfilePictureView *pictureView;
@property (strong, nonatomic) UIView *dimView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) NSObject<FriendPictureViewControllerDelegate> *delegate;

- (void)animateForward:(BOOL)forward onCompletion:(void(^)(BOOL completion))completion;

@end
