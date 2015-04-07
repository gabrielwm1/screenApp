//
//  AddButton.h
//  ButtonTest
//
//  Created by Mason Wolters on 11/19/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddButton : UIView {
    UIView *horizontalBar;
    UIView *verticalBar;
    BOOL isCheck;
    BOOL loadAsChecked;
}

@property (strong, nonatomic) UIColor *checkColor;
@property (strong, nonatomic) UIColor *plusColor;
@property (nonatomic) float lineWidth;
@property (nonatomic) float checkWidth;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;


- (void)animateToCheck;
- (void)animateToPlus;
- (void)goToCheck;

@end
