//
//  ProfilePictureView.h
//  Screen
//
//  Created by Mason Wolters on 11/17/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FBProfilePictureView.h>
#import <SDWebImage/UIImageView+WebCache.h>

@class PFUser;

typedef enum ProfilePictureSize{
    thumbnail,
    fullSize
} ProfilePictureSize;

@interface ProfilePictureView : UIView {
    FBProfilePictureView *fbPicView;
    UIImageView *imageView;
}

@property (strong, nonatomic) NSString *facebookId;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) ProfilePictureSize pictureSize;

@property (strong, nonatomic) PFUser *user;

@end
