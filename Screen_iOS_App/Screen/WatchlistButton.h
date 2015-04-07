//
//  WatchlistButton.h
//  Screen
//
//  Created by Mason Wolters on 12/2/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface WatchlistButton : UIButton

- (void)animateToGreenStateWithTitle:(NSString *)title;
- (void)animateToGrayStateWithTitle:(NSString *)title;

@end
