//
//  MovieSearchTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 11/7/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "MovieStatusButton.h"

@protocol MovieSearchCellDelegate <NSObject>

- (void)tappedAddButtonAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MovieSearchTableViewCell : UITableViewCell {
    UIView *selectionBackground;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *yearLabel;
@property (strong, nonatomic) IBOutlet MovieStatusButton *statusButton;
@property (weak, nonatomic) NSObject<MovieSearchCellDelegate> *delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

- (void)setImageURL:(NSURL *)url;

@end
