//
//  ScreenViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/15/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "ScreenLogInViewController.h"

@interface ScreenLogInViewController ()

@end

@implementation ScreenLogInViewController

- (id)init {
    self = [super init];
    
    if (self) {
//        self.facebookPermissions = @[@"friends_about_me"];
        self.facebookPermissions = @[@"user_friends"];
        [self setFields:PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsTwitter];
        self.signUpController = [[ScreenSignUpViewController alloc] init];
    }
    
    return self;
}

- (void)viewDidLayoutSubviews {
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.logInView.bounds];
    background.image = [UIImage imageNamed:@"background"];
    background.contentMode = UIViewContentModeScaleAspectFill;
    [self.logInView insertSubview:background atIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setFields:PFLogInFieldsFacebook];
    
    self.logInView.backgroundColor = [UIColor whiteColor];
    self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLogo"]];
    self.logInView.emailAsUsername = YES;

    
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
