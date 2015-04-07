//
//  NowPlayingTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 1/9/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieStatusButton.h"

@class DemandBarView;

@protocol NowPlayingCellDelegate <NSObject>

- (void)tappedAddButtonAtIndexPath:(NSIndexPath *)indexPath;
- (void)tappedAddButtonOnCell:(id)cell;

@end

@interface NowPlayingTableViewCell : UITableViewCell {
    UIView *selectionBackground;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet DemandBarView *demandBarView;
@property (strong, nonatomic) IBOutlet UILabel *demandLabel;
@property (strong, nonatomic) IBOutlet MovieStatusButton *statusButton;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) NSObject<NowPlayingCellDelegate> *delegate;
@property (strong, nonatomic) UIView *separator;

@end
