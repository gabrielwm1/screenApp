//
//  ShowtimeTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 12/3/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import <PureLayout/PureLayout.h>

@interface ShowtimeTableViewCell : UITableViewCell {
    UIView *selectionBackground;
    BOOL didUpdateContstraints;
}

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timesLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) UIView *separator;

@end
