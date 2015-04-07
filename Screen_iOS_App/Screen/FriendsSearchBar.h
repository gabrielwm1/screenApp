//
//  FriendsSearchBar.h
//  Screen
//
//  Created by Mason Wolters on 11/16/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol FriendsSearchBarDelegate <NSObject>

- (void)didChangeSearchText:(NSString *)searchText;

@optional
- (void)didStartEditing;
- (void)cancelPress;
- (void)willBeginEditing;

@end

@interface FriendsSearchBar : UIView <UITextFieldDelegate> {
    BOOL cancelButtonIn;
    UIButton *clearButton;
}

@property (strong, nonatomic) UIImageView *searchImage;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (weak, nonatomic) NSObject<FriendsSearchBarDelegate> *delegate;

- (void)initialize;
- (void)animateCancelButtonIn:(BOOL)toIn duration:(float)duration;
- (void)showCancelButtonUnanimated:(BOOL)toIn;

@end
