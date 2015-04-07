//
//  TheaterShowtimeTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 12/4/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface TheaterShowtimeTableViewCell : UITableViewCell {
    UIView *selectionBackground;
    BOOL didUpdateConstraints;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timesLabel;

@end
