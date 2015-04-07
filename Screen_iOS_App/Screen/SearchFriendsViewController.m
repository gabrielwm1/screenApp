//
//  SearchFriendsViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/16/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "SearchFriendsViewController.h"
#import "WatchlistsViewController.h"

@interface SearchFriendsViewController ()

@end

@implementation SearchFriendsViewController

@synthesize backgroundImage;
@synthesize searchBar;
@synthesize tableView;
@synthesize delegate;

#pragma mark - Public

- (void)animateInWithDuration:(float)duration {
    backgroundImage.alpha = 0.0f;
    tableView.alpha = 0.0f;
    searchBar.alpha = 0.0f;
    [searchBar showCancelButtonUnanimated:YES];
    [UIView animateWithDuration:.2f animations:^{
        backgroundImage.alpha = 1.0f;
        tableView.alpha = 1.0f;
    }];
    
}

#pragma mark - Search Delegate

- (void)didStartEditing {
    
}

- (void)didChangeSearchText:(NSString *)searchText {
    [[ParseHelper sharedInstance] searchUsers:searchText success:^(NSArray *results) {
        users = results;
        [tableView reloadData];
    }error:^(NSError *error) {
        
    }];
}

- (void)cancelPress {
    [self dismiss];
}

#pragma mark - Private

- (void)finishIntro {
    searchBar.alpha = 1.0f;
    [searchBar.textField becomeFirstResponder];
}

- (void)animateOut:(void(^)(BOOL finished))complete {
    [searchBar animateCancelButtonIn:NO duration:.5f];
    [UIView animateWithDuration:.2f animations:^{
        tableView.alpha = 0.0f;
        backgroundImage.alpha = 0.0f;
    }];
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        searchBar.center = CGPointMake(self.view.frame.size.width/2, 81.5);
    }completion:complete];
}

- (void)dismiss {
    [searchBar resignFirstResponder];
    self.transitioningDelegate = [STPTransitionCenter sharedInstance];
    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *container, void(^Complete)(BOOL finished)) {
        [self animateOut:(^(BOOL finished) {
            [[toView viewWithTag:101] setAlpha:1.0f];
            Complete(finished);
        })];
    }];
    
    [self dismissViewControllerUsingTransition:transition onCompletion:nil];
}

#pragma mark - Friend Request

- (void)friendRequestButton:(FriendRequestButton *)button changedTypeTo:(ButtonType)type {
    if (type == buttonTypeWaiting) {
        //user just friend requested someone
        int index = button.index;
        NSLog(@"friend request");
        [[ParseHelper sharedInstance] sendFriendRequestToUser:users[index] success:^{
            NSLog(@"friend request success");
        }error:^(NSError *error) {
            NSLog(@"friend request error: %@", error.description);
        }];
    } else if (type == buttonTypeFriends) {
        //user just confirmed friend request
        PFUser *user = users[button.index];
        [[ParseHelper sharedInstance] acceptFriendRequestFromUser:user success:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didAcceptRequestInSearch" object:nil];
        }error:^(NSError *error) {
            
        }];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    PFUser *user = users[indexPath.row];
    cell.titleLabel.text = [user objectForKey:@"name"];
    
    if (user[@"fbId"] && ![user[@"fbId"] isEqualToString:@""]) {
        cell.profilePictureView.facebookId = user[@"fbId"];
    } else {
        cell.profilePictureView.imageURL = nil;
    }
    
    cell.friendRequestButton.index = (int)indexPath.row;
    cell.friendRequestButton.delegate = self;
    
    cell.buttonType = buttonTypeAdd;
    
    [[ParseHelper sharedInstance] userHasRequestedUser:user success:^(BOOL hasRequested) {
        if (hasRequested) cell.buttonType = buttonTypeWaiting;
    }];
    [[ParseHelper sharedInstance] userIsFriendsWithUser:user success:^(BOOL isFriends) {
        if (isFriends) cell.buttonType = buttonTypeFriends;
    }];
    [[ParseHelper sharedInstance] userHasRequestedToBeFriends:user success:^(BOOL hasRequested) {
        if (hasRequested) cell.buttonType = buttonTypeRequested;
    }];
    
//    cell.buttonType = (indexPath.row % 2)?buttonTypeAdd:(indexPath.row%3)?buttonTypeFriends:buttonTypeWaiting;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    selectedUser = users[indexPath.row];
//    [self cancelPress];
//    [delegate selectedUser:selectedUser];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [searchBar.textField resignFirstResponder];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    
    searchBar.delegate = self;
    
    [self loadData];
}

- (void)loadData {
    [[ParseHelper sharedInstance] twitterParseFriendsQuery:^(PFQuery *query) {
        [self.tableView reloadData];
    }];
    [[ParseHelper sharedInstance] facebookFriendsParseQuery:^(PFQuery *query) {
        [self.tableView reloadData];
    }];
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
