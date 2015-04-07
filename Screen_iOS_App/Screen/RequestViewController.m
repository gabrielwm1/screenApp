//
//  RequestViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/14/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "RequestViewController.h"
#import "Constants.h"
#import <SZTextView/SZTextView.h>
#import "ParseHelper.h"

@interface RequestViewController () {
    SZTextView *textView;
    UITextField *titleField;
}

@end

@implementation RequestViewController

@synthesize passedTitle = _passedTitle;
@synthesize activityIndicator = _activityIndicator;

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        _activityIndicator.center = sendButton.center;
        [typingView addSubview:_activityIndicator];
    }
    
    return _activityIndicator;
}

- (void)setPassedTitle:(NSString *)passedTitle {
    _passedTitle = passedTitle;
    titleField.text = passedTitle;
}

- (void)sendPress {
    [titleField resignFirstResponder];
    [textView resignFirstResponder];
    self.activityIndicator.alpha = 1.0f;
    [self.activityIndicator startAnimating];
    sendButton.alpha = 0.0f;
    [[ParseHelper sharedInstance] requestMovieWithTitle:titleField.text description:textView.text success:^{
        [self gotoSuccess];
    }error:^(NSError *error) {
        self.activityIndicator.alpha = 0.0f;
        sendButton.alpha = 1.0f;
    }];
}

- (void)gotoSuccess {
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.7f initialSpringVelocity:.3f options:0 animations:^{
        typingView.transform = CGAffineTransformMakeTranslation(-innerView.bounds.size.width - 100, 0);
        successView.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        [self performSelector:@selector(tapView) withObject:nil afterDelay:1.0f];
    }];
}

- (void)animateInCompletion:(void (^)(BOOL))completion origin:(CGPoint)origin {
    innerView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(.5, .5), CGAffineTransformMakeTranslation(origin.x - self.view.center.x, origin.y - self.view.center.y));
    innerView.alpha = 0.0f;
    [UIView animateWithDuration:.5f delay:0.0f usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        backgroundView.alpha = .5f;
        innerView.transform = CGAffineTransformIdentity;
        innerView.alpha = 1.0f;
    }completion:completion];
}

- (void)tapView {
    self.transitioningDelegate = [STPTransitionCenter sharedInstance];
    
    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void(^executeOnComplete)(BOOL finished) ) {
        [UIView animateWithDuration:.2f animations:^{
            self.view.alpha = 0.0f;
        } completion:executeOnComplete ];
    }];
    
    [titleField resignFirstResponder];
    [textView resignFirstResponder]; 
    
    [self dismissViewControllerUsingTransition:transition onCompletion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *contents = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (!contents || [contents isEqualToString:@""]) {
        sendButton.enabled = NO;
        sendButton.alpha = .3f;
    } else {
        sendButton.enabled = YES;
        sendButton.alpha = 1.0f;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textView becomeFirstResponder];
    return YES;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    
    backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.0f;
    [backgroundView addGestureRecognizer:tap];
    [self.view addSubview:backgroundView];
    
    innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 50, 222)];
    innerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 - 100);
    innerView.backgroundColor = UIColorFromRGB(grayColor);
    innerView.layer.cornerRadius = 5.0f;
    innerView.layer.masksToBounds = YES;
    [self.view addSubview:innerView];
    
    typingView = [[UIView alloc] initWithFrame:innerView.bounds];
    [innerView addSubview:typingView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 5, innerView.bounds.size.width - 32, 40)];
    title.text = @"Request Film";
    title.textColor = [UIColor whiteColor];
    [typingView addSubview:title];
    
    sendButton = [[UIButton alloc] initWithFrame:CGRectMake(innerView.bounds.size.width - 16 - 50, 5, 50, 40)];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton setTitleColor:UIColorFromRGB(blueColor) forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColorFromRGB(blueColor) colorWithAlphaComponent:.5f] forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(sendPress) forControlEvents:UIControlEventTouchUpInside];
    if (!self.passedTitle || [self.passedTitle isEqualToString:@""]) {
        sendButton.enabled = NO;
        sendButton.alpha = .3f;
    }
    [typingView addSubview:sendButton];
    
    UIView *titleBox = [[UIView alloc] initWithFrame:CGRectMake(16, 50, innerView.bounds.size.width - 32, 40)];
    titleBox.backgroundColor = UIColorFromRGB(darkGrayColor);
    titleBox.layer.cornerRadius = 5.0f;
    [typingView addSubview:titleBox];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(titleBox.bounds, 10, 0)];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"Title:";
    [titleBox addSubview:titleLabel];
    
    titleField = [[UITextField alloc] initWithFrame:CGRectMake(50, 0, titleBox.frame.size.width - 55, titleBox.frame.size.height)];
    titleField.font = [UIFont systemFontOfSize:14.0f];
    titleField.textColor = [UIColor whiteColor];
    titleField.text = self.passedTitle;
    titleField.autocorrectionType = UITextAutocorrectionTypeNo;
    titleField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    titleField.returnKeyType = UIReturnKeyNext;
    titleField.delegate = self;
    [titleBox addSubview:titleField];
    
    UIView *descriptionBox = [[UIView alloc] initWithFrame:CGRectMake(15, 106, innerView.bounds.size.width - 32, 100)];
    descriptionBox.backgroundColor = UIColorFromRGB(darkGrayColor);
    descriptionBox.layer.cornerRadius = 5.0f;
    [typingView addSubview:descriptionBox];
    
    textView = [[SZTextView alloc] initWithFrame:CGRectInset(descriptionBox.bounds, 6, 2)];
    textView.backgroundColor = [UIColor clearColor];
    textView.placeholder = @"More Information";
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:14.0f];
    textView.delegate = self;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    [descriptionBox addSubview:textView];
    
    successView = [[UIView alloc] initWithFrame:innerView.bounds];
    successView.transform = CGAffineTransformMakeTranslation(innerView.bounds.size.width, 0);
    [innerView addSubview:successView];
    
    UILabel *successLabel = [[UILabel alloc] initWithFrame:successView.bounds];
    successLabel.textAlignment = NSTextAlignmentCenter;
    successLabel.textColor = [UIColor whiteColor];
    successLabel.text = @"We'll let you know.";
    [successView addSubview:successLabel];
    
    [titleField becomeFirstResponder];
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
