//
//  RadiusSelectorView.h
//  Screen
//
//  Created by Mason Wolters on 12/16/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeBlock)(void);

@interface RadiusSelectorView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) ChangeBlock changeHandler;
@property (strong, nonatomic) ChangeBlock pickLocationHandler;
@property (strong, nonatomic) UILabel *locationLabel;

- (void)update;

@end
