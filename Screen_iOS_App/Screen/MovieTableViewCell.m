//
//  MovieTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 11/6/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "MovieTableViewCell.h"

@implementation MovieTableViewCell

@synthesize sortType = _sortType;
@synthesize imageView;

- (void)setSortType:(SortType)sortType {
    _sortType = sortType;
}

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //    [super setHighlighted:highlighted animated:animated];
    
    self.contentView.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    self.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (animated) {
        [UIView animateWithDuration:.2f animations:^{
            self.contentView.backgroundColor = (selected)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
        }];
    } else {
        self.contentView.backgroundColor = (selected)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    }
}

@end
