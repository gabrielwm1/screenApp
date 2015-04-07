//
//  FriendPictureViewController.m
//  Screen
//
//  Created by Mason Wolters on 2/18/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "FriendPictureViewController.h"
#import <STPTransitions/STPTransitions.h>

@interface FriendPictureViewController ()

@end

@implementation FriendPictureViewController

@synthesize startingPictureRect;
@synthesize user;
@synthesize pictureView = _pictureView;
@synthesize dimView = _dimView;
@synthesize nameLabel = _nameLabel;
@synthesize delegate;

- (void)animateForward:(BOOL)forward onCompletion:(void (^)(BOOL))completion {
    if (forward) {
        [self.view addSubview:self.dimView];
        [self.view addSubview:self.nameLabel];
        [self.view addSubview:self.pictureView];
    }
    
    if (forward) self.pictureView.frame = startingPictureRect;
    
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        if (forward) {
            self.pictureView.frame = CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.width/2);
            self.pictureView.center = self.view.center;
        } else {
            self.pictureView.frame = startingPictureRect;
        }
        
    }completion:completion];
    [UIView animateWithDuration:.3f animations:^{
        self.nameLabel.alpha = (forward)?1.0f:0.0f;
        self.dimView.alpha = (forward)?.7f:0.0f;
    }];
}

- (void)cancel {
    self.transitioningDelegate = [STPTransitionCenter sharedInstance];
    
    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void (^executeOnComplete)(BOOL finished)) {
//        [containerView insertSubview:toView belowSubview:fromView];
        [self animateForward:NO onCompletion:^(BOOL finished) {
            [delegate dismissedFriendPictureViewController];
            executeOnComplete(YES);
        }];
    }];
    
    [self dismissViewControllerUsingTransition:transition onCompletion:nil];
}

- (ProfilePictureView *)pictureView {
    if (!_pictureView) {
        _pictureView = [[ProfilePictureView alloc] init];
        _pictureView.pictureSize = fullSize;
        _pictureView.user = user;
    }
    
    return _pictureView;
}

- (UIView *)dimView {
    if (!_dimView) {
        _dimView = [[UIView alloc] initWithFrame:self.view.bounds];
        _dimView.backgroundColor = [UIColor blackColor];
        _dimView.alpha = 0.0f;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
        [_dimView addGestureRecognizer:tap];
    }
    
    return _dimView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20, 40)];
        _nameLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - self.view.frame.size.height/4);
        _nameLabel.text = user[@"name"];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:32.0f];
        _nameLabel.alpha = 0.0f;
    }
    
    return _nameLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
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
