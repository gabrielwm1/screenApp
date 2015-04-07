//
//  Tomatometer.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface Tomatometer : UIView {
    UIView *redView;
}

@property (nonatomic) IBInspectable float percentage;

@end
