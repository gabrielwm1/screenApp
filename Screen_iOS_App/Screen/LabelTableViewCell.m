//
//  LabelTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 12/22/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "LabelTableViewCell.h"

@implementation LabelTableViewCell

@synthesize label;

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    label.frame = self.contentView.bounds;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15.0f];
        [self.contentView addSubview:label];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
