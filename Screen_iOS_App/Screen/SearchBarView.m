//
//  SearchBarView.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "SearchBarView.h"

@implementation SearchBarView

@synthesize textField;
@synthesize outlineView;
@synthesize cancelButton;
@synthesize searchImage;
@synthesize delegate;

- (void)clearTap {
    textField.text = @"";
    clearButton.alpha = 0.0f;
    [delegate didChangeSearchText:@""];
    [textField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField1 shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *searchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    clearButton.alpha = 1.0f;
    
    [delegate didChangeSearchText:searchText];
    
    return YES;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
//        self.backgroundColor = [UIColor orangeColor];
        
        outlineView = [[UIView alloc] initWithFrame:CGRectMake(.5, .5, frame.size.width - 1, frame.size.height - 1)];
        outlineView.layer.borderColor = UIColorFromRGB(blueColor).CGColor;
        outlineView.layer.cornerRadius = 5.0f;
        outlineView.layer.borderWidth = 1.0f;
        outlineView.layer.masksToBounds = YES;
        [self addSubview:outlineView];

        textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, frame.size.width - 40 - 60, frame.size.height)];
        textField.textColor = [UIColor whiteColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.tintColor = [UIColor whiteColor];
        textField.delegate = self;
        
        clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton setImage:[UIImage imageNamed:@"clearField.png"] forState:UIControlStateNormal];
        [clearButton setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)]; // Required for iOS7
        [clearButton addTarget:self action:@selector(clearTap) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        clearButton.alpha = 0.0f;
        textField.rightView = clearButton;
        textField.rightViewMode = UITextFieldViewModeAlways;

        [self addSubview:textField];
        
        cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 60, 0, 60, frame.size.height)];
        [cancelButton setBackgroundColor:UIColorFromRGB(blueColor)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.5f] forState:UIControlStateHighlighted];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        [outlineView addSubview:cancelButton];
        
        searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        searchImage.center = CGPointMake(22, frame.size.height/2);
        searchImage.image = [UIImage imageNamed:@"searchIconSmall"];
        [self addSubview:searchImage];
        

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
