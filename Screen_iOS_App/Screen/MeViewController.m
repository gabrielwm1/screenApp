//
//  MeViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/21/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "MeViewController.h"
#import "WatchlistsViewController.h"

@interface MeViewController ()

@end

@implementation MeViewController

@synthesize titleLabel;
@synthesize nameField;
@synthesize emailField;

#pragma mark - Private

- (void)facebookTap {
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        facebookConfirm = [[UIActionSheet alloc] initWithTitle:@"Log out of Facebook?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:nil];
        [facebookConfirm showInView:self.view];
    } else {
        [facebookButton setLoading:YES];
        
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:@[@"user_friends"] block:^(BOOL succeeded, NSError *error) {
            NSLog(@"succeeded linking facebook: %@, %@", (succeeded)?@"YES":@"NO", (error)?error.description:@"no error");
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Store the current user's Facebook ID on the user
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                             forKey:@"fbId"];
                    [[PFUser currentUser] saveInBackground];
                }
            }];
        }];
    }
}

- (void)twitterTap {
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        twitterConfirm = [[UIActionSheet alloc] initWithTitle:@"Log out of Twitter?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:nil];
        [twitterConfirm showInView:self.view];
    } else {
        [twitterButton setLoading:YES];
        
        [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:[PFTwitterUtils twitter].userId forKey:@"twitterId"];
                [[PFUser currentUser] saveInBackground];
                
                [[ParseHelper sharedInstance] twitterGetNameImage:^(NSString *name, NSString *userName, NSString *image) {
                    [[PFUser currentUser] setObject:image forKey:@"twitterImageUrl"];
                    [[PFUser currentUser] saveInBackground];
                }error:^(NSError *error) {
                    
                }];
                
                NSLog(@"succeeded linking twitter: %@, %@", (succeeded)?@"YES":@"NO", (error)?error.description:@"no error");
            }
        }];
    }
}

- (void)logoutTap {
    [[ParseHelper sharedInstance] logout];
    [self.navigationController.tabBarController setSelectedIndex:0];
    
    WatchlistsViewController *watchlistsController = (WatchlistsViewController *)[(UINavigationController *)self.tabBarController.viewControllers[0] viewControllers][0];
    [watchlistsController setMovies:nil];
    [watchlistsController setSeenMovies:nil];
    [[watchlistsController tableView] reloadData];
    [watchlistsController showLogin];
}

- (void)tapProfileImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickImageSheet = [[UIActionSheet alloc] initWithTitle:@"Change Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Photo", @"Take Photo", nil];
        [pickImageSheet showInView:self.view];
    } else {
        [self showImagePickerForType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:facebookConfirm] && buttonIndex == 0) {
        NSLog(@"delete facebook");
        [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            [facebookButton removeFromSuperview];
            facebookButton = nil;
            [self viewDidLayoutSubviews];
        }];
    } else if ([actionSheet isEqual:twitterConfirm] && buttonIndex == 0) {
        NSLog(@"delete twitter");
        [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            [twitterButton removeFromSuperview];
            twitterButton = nil;
            [self viewDidLayoutSubviews];
        }];
    } else if ([actionSheet isEqual:pickImageSheet]) {
        if (buttonIndex == 2) return;
        [self showImagePickerForType:(buttonIndex == 0)?UIImagePickerControllerSourceTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)showImagePickerForType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = type;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
    if (type == UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.profilePictureView.image = image;
    
    PFFile *picture;
    if ([image size].height > 500) {
        picture = [PFFile fileWithData:UIImageJPEGRepresentation([self imageResize:image andResizeTo:CGSizeMake(500, 500)], .7) contentType:@"image/jpeg"];
    } else {
        picture = [PFFile fileWithData:UIImageJPEGRepresentation(image, .7) contentType:@"image/jpeg"];
    }
    PFFile *thumbnail = [PFFile fileWithData:UIImageJPEGRepresentation([self imageResize:image andResizeTo:CGSizeMake(50, 50)], .7f) contentType:@"image/jpeg"];

    [[PFUser currentUser] setObject:thumbnail forKey:@"pictureThumbnail"];
    [[PFUser currentUser] setObject:picture forKey:@"picture"];
    [[PFUser currentUser] saveInBackground];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [[PFUser currentUser] setObject:nameField.text forKey:@"name"];
    [[PFUser currentUser] setObject:[nameField.text lowercaseString] forKey:@"lowercaseName"];
    [[PFUser currentUser] saveInBackground];
    
    return YES;
}

#pragma mark - UIViewController

- (void)viewDidLayoutSubviews {
    if (!facebookButton) {
        PFActionButtonConfiguration *configuration = [[PFActionButtonConfiguration alloc] initWithBackgroundImageColor:[PFColor facebookButtonBackgroundColor] image:[PFImage imageNamed:@"facebook_icon.png"]];
        
        NSString *facebookTitle = NSLocalizedString(@"Facebook", @"Facebook");
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) facebookTitle = @"Logged In";
        [configuration setTitle:facebookTitle forButtonStyle:PFActionButtonStyleNormal];
        [configuration setTitle:NSLocalizedString(@"Log In with Facebook", @"Log In with Facebook") forButtonStyle:PFActionButtonStyleWide];
        
        facebookButton = [[PFActionButton alloc] initWithConfiguration:configuration buttonStyle:PFActionButtonStyleNormal];
        
        facebookButton.frame = CGRectMake(0, 0, self.facebookView.frame.size.width, self.facebookView.frame.size.height);
        [self.facebookView addSubview:facebookButton];
        [facebookButton addTarget:self action:@selector(facebookTap) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!twitterButton) {
        PFActionButtonConfiguration *twitterConfig = [[PFActionButtonConfiguration alloc] initWithBackgroundImageColor:[PFColor twitterButtonBackgroundColor]
                                                                                                                 image:[PFImage imageNamed:@"twitter_icon.png"]];
        NSString *twitterTitle = NSLocalizedString(@"Twitter", @"Twitter");
        if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) twitterTitle = @"Logged In";
        [twitterConfig setTitle:twitterTitle forButtonStyle:PFActionButtonStyleNormal];
        [twitterConfig setTitle:NSLocalizedString(@"Log In with Twitter", @"Log In with Twitter") forButtonStyle:PFActionButtonStyleWide];
        
        twitterButton = [[PFActionButton alloc] initWithConfiguration:twitterConfig buttonStyle:PFActionButtonStyleNormal];
        
        twitterButton.frame = CGRectMake(0, 0, self.twitterView.frame.size.width, self.twitterView.frame.size.height);
        [self.twitterView addSubview:twitterButton];
        [twitterButton addTarget:self action:@selector(twitterTap) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!logoutButton) {
        PFActionButtonConfiguration *logoutConfig = [[PFActionButtonConfiguration alloc] initWithBackgroundImageColor:[PFColor loginButtonBackgroundColor] image:nil];
        
        [logoutConfig setTitle:@"Logout" forButtonStyle:PFActionButtonStyleWide];
    
        logoutButton = [[PFActionButton alloc] initWithConfiguration:logoutConfig buttonStyle:PFActionButtonStyleWide];
        logoutButton.frame = CGRectMake(0, 0, self.logoutView.frame.size.width, self.logoutView.frame.size.height);
        [self.logoutView addSubview:logoutButton];
        [logoutButton addTarget:self action:@selector(logoutTap) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40) duration:8.0f andFadeLength:10.0f];
    titleLabel.text = @"My Account";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    self.facebookView.backgroundColor = [UIColor clearColor];
    self.twitterView.backgroundColor = [UIColor clearColor];
    self.logoutView.backgroundColor = [UIColor clearColor];
    
    self.profilePictureView.imageURL = nil;
    
    emailField.text = [[PFUser currentUser] objectForKey:@"username"];
    nameField.text = [[PFUser currentUser] objectForKey:@"name"];
    nameField.delegate = self;
    
    UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileImage)];
    [self.profilePictureView addGestureRecognizer:tapProfile];
    
//    if ([[PFUser currentUser] objectForKey:@"fbId"] && ![[[PFUser currentUser] objectForKey:@"fbId"] isEqualToString:@""]) {
//        self.profilePictureView.facebookId = [[PFUser currentUser] objectForKey:@"fbId"];
//    } else {
//        self.profilePictureView.imageURL = nil;
//    }
    self.profilePictureView.pictureSize = fullSize;
    self.profilePictureView.user = [PFUser currentUser];
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
