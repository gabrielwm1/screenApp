//
//  ScreenSignUpViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/18/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "ScreenSignUpViewController.h"

@interface ScreenSignUpViewController ()

@end

@implementation ScreenSignUpViewController

- (id)init {
    self = [super init];
    
    if (self) {
        self.signUpView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLogo"]];
//        self.emailAsUsername = YES;
        self.signUpView.usernameField.placeholder = @"Name";
        self.signUpView.usernameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.signUpView.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.signUpView.passwordField.placeholder = @"Email";
        self.signUpView.passwordField.secureTextEntry = NO;
        self.signUpView.emailField.placeholder = @"Password";
        self.signUpView.emailField.secureTextEntry = YES;
    }
    
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.signUpView.bounds];
    background.image = [UIImage imageNamed:@"background"];
    background.contentMode = UIViewContentModeScaleAspectFill;
    [self.signUpView insertSubview:background atIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
