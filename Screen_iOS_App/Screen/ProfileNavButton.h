//
//  ProfileNavButton.h
//  Screen
//
//  Created by Mason Wolters on 11/21/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfilePictureView.h"
#import "ParseHelper.h"

@protocol ProfileNavButtonDelegate <NSObject>

- (void)didTapProfileNavButton;

@end

@interface ProfileNavButton : UIView

@property (strong, nonatomic) ProfilePictureView *profileView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) NSObject<ProfileNavButtonDelegate> *delegate;

@end
