//
//  FriendsSearchBar.m
//  Screen
//
//  Created by Mason Wolters on 11/16/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "FriendsSearchBar.h"

@implementation FriendsSearchBar

@synthesize searchImage;
@synthesize textField;
@synthesize backgroundView;
@synthesize cancelButton;
@synthesize delegate;

- (void)cancelPress {
    if ([delegate respondsToSelector:@selector(cancelPress)]) {
        [delegate cancelPress];
    }
}

- (void)animateCancelButtonIn:(BOOL)toIn duration:(float)duration {
    self.backgroundView.frame = [self backgroundViewFrameSmall:!toIn];
    cancelButtonIn = toIn;

    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        self.backgroundView.frame = [self backgroundViewFrameSmall:toIn];
        self.cancelButton.frame = [self cancelButtonFrameIn:toIn];
    }completion:^(BOOL finished) {
    }];
}

- (void)showCancelButtonUnanimated:(BOOL)toIn {
    cancelButtonIn = toIn;
    self.backgroundView.frame = [self backgroundViewFrameSmall:toIn];
    self.cancelButton.frame = [self cancelButtonFrameIn:toIn];
}

- (void)clearTap {
    textField.text = @"";
    clearButton.alpha = 0.0f;
    if ([delegate respondsToSelector:@selector(didChangeSearchText:)]) {
        [delegate didChangeSearchText:@""];
    }
    [textField becomeFirstResponder];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([delegate respondsToSelector:@selector(willBeginEditing)]) {
        [delegate willBeginEditing];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([delegate respondsToSelector:@selector(didStartEditing)]) {
        [delegate didStartEditing];
    }
}

- (BOOL)textField:(UITextField *)textField1 shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *searchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    clearButton.alpha = 1.0f;
    if ([delegate respondsToSelector:@selector(didChangeSearchText:)]) {
        [delegate didChangeSearchText:searchText];
    }
    
    return YES;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    [self.textField resignFirstResponder];
    return YES;
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    [self.textField becomeFirstResponder];
    return YES;
}

- (CGRect)backgroundViewFrameSmall:(BOOL)small {
    return CGRectMake(0, 0, (small)?self.frame.size.width - 60:self.frame.size.width, self.frame.size.height);
}

- (CGRect)cancelButtonFrameIn:(BOOL)isIn {
    return CGRectMake((isIn)?self.frame.size.width-60:self.frame.size.width, 0, 60, self.frame.size.height);
}

#pragma mark - Initialization

- (void)layoutSubviews {
    [super layoutSubviews];
    
    searchImage.center = CGPointMake(22, self.frame.size.height/2);
    textField.frame = CGRectMake(40, 0, (cancelButtonIn)?self.frame.size.width - 40 - 60:self.frame.size.width - 40, self.frame.size.height);
    backgroundView.frame = [self backgroundViewFrameSmall:cancelButtonIn];
    cancelButton.frame = [self cancelButtonFrameIn:cancelButtonIn];
}

- (void)awakeFromNib {
    [self initialize];
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    
    backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = UIColorFromRGB(0x2b3844);
    backgroundView.layer.cornerRadius = 5.0f;
    [self addSubview:backgroundView];
    
    searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    searchImage.center = CGPointMake(22, self.frame.size.height/2);
    searchImage.image = [UIImage imageNamed:@"searchIconSmall"];
    [self addSubview:searchImage];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, self.frame.size.width - 40, self.frame.size.height)];
    textField.textColor = [UIColor whiteColor];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.tintColor = [UIColor whiteColor];
    textField.delegate = self;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Find More Friends" attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0xb5b5b5), NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]}];
    [self addSubview:textField];
    
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"clearField.png"] forState:UIControlStateNormal];
    [clearButton setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)]; // Required for iOS7
    [clearButton addTarget:self action:@selector(clearTap) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    clearButton.alpha = 0.0f;
    textField.rightView = clearButton;
    textField.rightViewMode = UITextFieldViewModeAlways;
    
    cancelButton = [[UIButton alloc] initWithFrame:[self cancelButtonFrameIn:NO]];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColorFromRGB(blueColor) forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColorFromRGB(blueColor) colorWithAlphaComponent:.5f] forState:UIControlStateHighlighted];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    [cancelButton addTarget:self action:@selector(cancelPress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
