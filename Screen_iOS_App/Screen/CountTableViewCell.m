//
//  CountTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 3/27/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "CountTableViewCell.h"

@implementation CountTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
