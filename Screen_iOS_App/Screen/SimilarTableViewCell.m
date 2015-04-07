//
//  SimilarTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 12/29/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "SimilarTableViewCell.h"
#import "SimilarMoviesView.h"

@implementation SimilarTableViewCell

@synthesize similarMoviesView;

- (void)updateConstraints {
    if (!didUpdateConstraints) {
        didUpdateConstraints = YES;
        
        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[similarMoviesView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(similarMoviesView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[similarMoviesView(120)]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(similarMoviesView)]];
    }
    
    [super updateConstraints];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        similarMoviesView = [[SimilarMoviesView alloc] init];
        [similarMoviesView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:similarMoviesView];
        
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
