//
//  SearchBarView.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol SearchBarDelegate <NSObject>

- (void)didChangeSearchText:(NSString *)searchText;

@end

@interface SearchBarView : UIView <UITextFieldDelegate> {
    UIButton *clearButton;
}

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIView *outlineView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIImageView *searchImage;
@property (weak, nonatomic) NSObject<SearchBarDelegate> *delegate;

@end
