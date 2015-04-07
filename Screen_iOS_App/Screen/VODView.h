//
//  VODView.h
//  Screen
//
//  Created by Mason Wolters on 2/20/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnConnectHelper.h"

@interface VODView : UIView

@property (nonatomic) VODAvailability *vodAvailability;

@property (strong, nonatomic) UIImageView *imageView;

@end
