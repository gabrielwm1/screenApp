//
//  NoBackgroundTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 12/3/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoBackgroundTableViewCell : UITableViewCell {
    UIView *selectionBackground;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end