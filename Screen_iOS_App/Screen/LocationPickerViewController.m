//
//  LocationPickerViewController.m
//  Screen
//
//  Created by Mason Wolters on 12/31/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "LocationPickerViewController.h"
#import "GooglePlacesHelper.h"
#import "NoBackgroundTableViewCell.h"

@interface LocationPickerViewController ()

@end

@implementation LocationPickerViewController

@synthesize tableView;
@synthesize searchBar;
@synthesize delegate;

#pragma mark - Search Bar Delegate

- (void)didChangeSearchText:(NSString *)searchText {
    [[GooglePlacesHelper sharedInstance] searchSuggestionsForQuery:searchText success:^(NSArray *results) {
        places = results;
        [self.tableView reloadData];
    }error:^(NSError *error) {
        
    }];
}

- (void)cancelPress {
    [searchBar.textField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return places.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentLocationCell"];
        
        return cell;
    } else {
        NoBackgroundTableViewCell *cell = (NoBackgroundTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        SPGooglePlacesAutocompletePlace *place = places[indexPath.row];
        cell.titleLabel.text = place.name;
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [delegate pickedCurrentLocation];
        [searchBar.textField resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        SPGooglePlacesAutocompletePlace *place = places[indexPath.row];
        [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *address, NSError *error) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Pick a different location" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            } else {
                [delegate pickedLocationWithName:place.name coordinate:placemark.location];
            }
        }];
        [searchBar.textField resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [searchBar.textField resignFirstResponder];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    tableView.backgroundColor = [UIColor clearColor];
    
    [searchBar showCancelButtonUnanimated:YES];
    searchBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search for locations" attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0xb5b5b5), NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]}];
    searchBar.delegate = self;
    [searchBar.textField becomeFirstResponder];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UIImageView *poweredByGoogle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 104, 16)];
    [poweredByGoogle setImage:[UIImage imageNamed:@"powered-by-google"]];
    poweredByGoogle.center = CGPointMake(footer.frame.size.width/2, footer.frame.size.height/2);
    [footer addSubview:poweredByGoogle];
    
    self.tableView.tableFooterView = footer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
