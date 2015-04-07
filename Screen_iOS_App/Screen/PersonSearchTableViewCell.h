//
//  PersonTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 11/13/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface PersonSearchTableViewCell : UITableViewCell {
    UIView *selectionBackground;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topSpaceToImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceToImageView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
