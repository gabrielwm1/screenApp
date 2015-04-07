//
//  PFLoginBlocks.h
//  Screen
//
//  Created by Mason Wolters on 11/15/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef void(^ErrorBlock)(NSError *error);
typedef void(^CancelBlock)(void);
typedef void(^UserBlock)(PFUser *user);

@interface PFLoginBlocks : NSObject

@property (strong, nonatomic) ErrorBlock errorLoggingIn;
@property (strong, nonatomic) ErrorBlock errorSigningUp;
@property (strong, nonatomic) CancelBlock cancelLogIn;
@property (strong, nonatomic) CancelBlock cancelSignUp;
@property (strong, nonatomic) UserBlock didLogInUser;
@property (strong, nonatomic) UserBlock didSignUpUser;

@end
