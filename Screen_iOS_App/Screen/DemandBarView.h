//
//  DemandBarView.h
//  Screen
//
//  Created by Mason Wolters on 11/14/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemandBarView : UIView {
    UIImage *image;
    CGRect frame;
}

@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic) float percentage;

@end
