//
//  MWPopoverView.h
//  SailingTimer
//
//  Created by Mason Wolters on 7/22/14.
//  Copyright (c) 2014 Mason Wolters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>
#import "Constants.h"

typedef enum {
    mwPopoverPositionAuto,
    mwPopoverPositionTop,
    mwPopoverPositionRight,
    mwPopoverPositionLeft,
    mwPopoverPositionBottom
} MWPopoverPosition;

@interface MWPopoverView : UIView {
}

@property (weak, nonatomic) UIView *view;
@property (strong, nonatomic) UIView *dimView;
@property (strong, nonatomic) UIView *container;
@property (nonatomic) CGPoint displayPoint;
@property (nonatomic) CGSize targetSize;
@property (nonatomic) MWPopoverPosition popoverPosition;

@property (strong, nonatomic) UIColor *strokeColor;
@property (strong, nonatomic) UIColor *background;

+ (MWPopoverView*)popoverWithSize:(CGSize)size inView:(UIView*)view;

- (void)showFromPoint:(CGPoint)point;

- (void)hideWithDuration:(float)duration animationBlock:(void(^)(void))animations;

- (void)hide;

@end
