//
//  LocationPickerViewController.h
//  Screen
//
//  Created by Mason Wolters on 12/31/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FriendsSearchBar.h"

@protocol LocationPickerDelegate <NSObject>

- (void)pickedLocationWithName:(NSString *)name coordinate:(CLLocation *)coordinate;
- (void)pickedCurrentLocation;

@end

@interface LocationPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FriendsSearchBarDelegate> {
    NSArray *places;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet FriendsSearchBar *searchBar;
@property (weak, nonatomic) NSObject<LocationPickerDelegate> *delegate;

@end
