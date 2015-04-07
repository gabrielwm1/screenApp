//
//  MeViewController.h
//  Screen
//
//  Created by Mason Wolters on 11/21/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MarqueeLabel/MarqueeLabel.h>
#import "ProfilePictureView.h"
#import "PFActionButton.h"
#import "PFColor.h"
#import "PFImage.h"
#import "ParseHelper.h"

@interface MeViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    PFActionButton *facebookButton;
    PFActionButton *twitterButton;
    PFActionButton *logoutButton;
    
    UIActionSheet *facebookConfirm;
    UIActionSheet *twitterConfirm;
    UIActionSheet *pickImageSheet;
}

@property (strong, nonatomic) MarqueeLabel *titleLabel;
@property (strong, nonatomic) IBOutlet ProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UIView *facebookView;
@property (strong, nonatomic) IBOutlet UIView *twitterView;
@property (strong, nonatomic) IBOutlet UIView *logoutView;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;

@end
