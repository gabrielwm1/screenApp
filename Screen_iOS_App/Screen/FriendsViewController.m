//
//  FriendsViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/15/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "FriendsViewController.h"
#import "WatchlistsViewController.h"
#import "LoadingTableViewCell.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

@synthesize searchBar;

- (void)selectedUser:(PFUser *)user {
    selectedUser = user;
    [self performSegueWithIdentifier:@"toFriendsWatchlist" sender:self];
}

- (void)showSearch {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchFriendsViewController *search = (SearchFriendsViewController*)[storyboard instantiateViewControllerWithIdentifier:@"searchFriends"];
    search.delegate = self;
    
    FriendsSearchBar *animateBar = [[FriendsSearchBar alloc] initWithFrame:searchBar.frame];
    
    self.transitioningDelegate = [STPTransitionCenter sharedInstance];
    STPBlockTransition *blockTransition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void(^ExecuteOnComplete)(BOOL finished) ) {
        
        searchBar.alpha = 0.0f;
        [containerView addSubview:toView];
        [search animateInWithDuration:.5f];
        animateBar.frame = [containerView convertRect:animateBar.frame fromView:self.view];
        [containerView addSubview:animateBar];
        [animateBar animateCancelButtonIn:YES duration:.5f];

        NSLog(@"searchbar: %@", NSStringFromCGRect(searchBar.frame));
        [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
            animateBar.center = CGPointMake(containerView.frame.size.width/2, 46.5);
        }completion:^(BOOL finished) {
            [search finishIntro];
            [animateBar removeFromSuperview];
            ExecuteOnComplete(finished);

        }];
        
    }];
    
    
    [self presentViewController:search usingTransition:blockTransition onCompletion:nil];
}

#pragma mark - SearchBar 

- (void)didStartEditing {
}

- (void)willBeginEditing {
    [self showSearch];
}

- (void)didChangeSearchText:(NSString *)searchText {
    
}

- (void)didAcceptRequestInSearch {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Private

- (IBAction)cancelPress:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapProfileNavButton {
    [self performSegueWithIdentifier:@"toMe" sender:self];
}

- (void)loadData {
    [[ParseHelper sharedInstance] friendRequests:^(NSArray *results) {
        friendRequests = results;
        [self.tableView reloadData];
    }error:^(NSError *error) {
        
    }];
    [[ParseHelper sharedInstance] getParseFriends:^(NSArray *results) {
        if (!parseFriends) {
            parseFriends = results;
            [self.tableView reloadData];
        }
    }error:^(NSError *error) {
        
    }];
    [[ParseHelper sharedInstance] friendsQuery:^(PFQuery *friendsQuery) {
        friendsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
//        [friendsQuery includeKey:@"ratings"];
        [friendsQuery addAscendingOrder:@"name"];
        [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (!error) {
                parseFriends = results;
                [self.tableView reloadData];
            }
        }];
    }];
//    [[ParseHelper sharedInstance] getParseFriends:^(NSArray *results) {
//        parseFriends = results;
//        [self.tableView reloadData];
//    }error:^(NSError *error) {
//        
//    }];
//    [[ParseHelper sharedInstance] facebookFriendsWithApp:^(NSArray *results) {
//        facebookFriends = results;
//        [self.tableView reloadData];
//    }error:^(NSError *error) {
//        
//    }];
//    [[ParseHelper sharedInstance] twitterFriends:^(NSArray *results) {
//        twitterFriends = results;
//        [self.tableView reloadData];
//    }error:^(NSError *error) {
//        
//    }];
}

- (void)_loginWithFacebook {
    
    [facebookButton setLoading:YES];
    
    [PFFacebookUtils linkUser:[PFUser currentUser] permissions:@[@"user_friends"] block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Store the current user's Facebook ID on the user
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                             forKey:@"fbId"];
                    [[PFUser currentUser] saveInBackground];
                }
            }];
            
            [facebookButton removeFromSuperview];
            facebookButton = nil;
            showFacebookButton = NO;
            [self refreshButtons];
            [self loadData];
        } else {
            [facebookButton setLoading:NO];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to login" message:@"An error occurred while logging into Facebook. Please try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}

- (void)_loginWithTwitter {
    
    [twitterButton setLoading:YES];
    
    [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[PFUser currentUser] setObject:[PFTwitterUtils twitter].userId forKey:@"twitterId"];
            [[PFUser currentUser] saveInBackground];
            
            [[ParseHelper sharedInstance] twitterGetNameImage:^(NSString *name, NSString *userName, NSString *image) {
                [[PFUser currentUser] setObject:image forKey:@"twitterImageUrl"];
                [[PFUser currentUser] saveInBackground];
            }error:^(NSError *error) {
                
            }];
            
            [twitterButton removeFromSuperview];
            twitterButton = nil;
            showTwitterButton = NO;
            [self refreshButtons];
            [self loadData];
        } else {
            [twitterButton setLoading:NO];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to login" message:@"An error occurred while logging into Twitter. Please try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}

- (void)refreshButtons{
    layoutCount = 0;
    [self viewDidLayoutSubviews];
    [self viewDidLayoutSubviews];
}

- (void)friendRequestButton:(FriendRequestButton *)button changedTypeTo:(ButtonType)type {
    if (type == buttonTypeFriends) {
        //user just confirmed friend request
        PFUser *user = friendRequests[button.index];
        [[ParseHelper sharedInstance] acceptFriendRequestFromUser:user success:^{
            
        }error:^(NSError *error) {
            
        }];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return friendRequests.count; break;
        case 1: return parseFriends.count; break;
        case 2: return facebookFriends.count; break;
        case 3: return twitterFriends.count; break;
        default: return 0; break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!parseFriends && !friendRequests) {
        LoadingTableViewCell *loading = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
        [loading start];
        return loading;
    }
    
    FriendTableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequestCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    
    if (indexPath.section == 0) {
        cell.friendRequestButton.buttonType = buttonTypeRequested;
        cell.friendRequestButton.index = (int)indexPath.row;
        cell.friendRequestButton.delegate = self;
        PFUser *user = friendRequests[indexPath.row];
        [[ParseHelper sharedInstance] userIsFriendsWithUser:user success:^(BOOL result) {
            if (result) cell.friendRequestButton.buttonType = buttonTypeFriends;
        }];
        cell.titleLabel.text = user[@"name"];
//        if (user[@"pictureThumbnail"]) {
//            
//        } else {
//            cell.profilePictureView.imageURL = nil;
//        }
        cell.profilePictureView.user = user;
    } else if (indexPath.section == 1) {
        PFUser *user = parseFriends[indexPath.row];
        cell.titleLabel.text = user[@"name"];
//        if (user[@"pictureThumbnail"]) {
//            
//        } else {
//            cell.profilePictureView.imageURL = nil;
//        }
        cell.profilePictureView.user = user;
    } else if (indexPath.section == 2) {
        NSDictionary<FBGraphUser> *user = facebookFriends[indexPath.row];
        cell.titleLabel.text = user.name;
        cell.profilePictureView.facebookId = user.objectID;
    } else if (indexPath.section == 3) {
        
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        selectedUser = friendRequests[indexPath.row];
        [self performSegueWithIdentifier:@"toFriendsWatchlist" sender:self];
    } else if (indexPath.section == 1) {
        selectedUser = parseFriends[indexPath.row];
        [self performSegueWithIdentifier:@"toFriendsWatchlist" sender:self];
    } else if (indexPath.section == 2) {
        selectedFriend = facebookFriends[indexPath.row];
        
        [[ParseHelper sharedInstance] userWithFacebookId:selectedFriend.objectID success:^(PFUser *user) {
            selectedUser = user;
            [self performSegueWithIdentifier:@"toFriendsWatchlist" sender:self];
        }error:^(NSError *error) {
            
        }];
    } else if (indexPath.section == 3) {
        
    }
    
    
}

#pragma mark - UIViewController

- (void)viewDidLayoutSubviews {
//    _facebookButton = [[PFActionButton alloc] initWithConfiguration:[[self class] _defaultFacebookButtonConfiguration]
//                                                        buttonStyle:PFActionButtonStyleNormal];
    layoutCount ++;
    if (showFacebookButton && !showTwitterButton) self.facebookHorizontalConstraint.constant = -7 - self.twitterView.frame.size.width;
    if (!showFacebookButton && showTwitterButton) self.twitterHorizontalConstraint.constant = -9 - self.facebookView.frame.size.width;
    if (!showFacebookButton && !showTwitterButton) self.tableViewTopSpaceConstraint.constant = self.searchBar.frame.size.height + 8;

    [self.view setNeedsLayout];
    
    if (showFacebookButton && !facebookButton && layoutCount == 2) {
        PFActionButtonConfiguration *configuration = [[PFActionButtonConfiguration alloc] initWithBackgroundImageColor:[PFColor facebookButtonBackgroundColor] image:[PFImage imageNamed:@"facebook_icon.png"]];
        
        [configuration setTitle:NSLocalizedString(@"Facebook", @"Facebook") forButtonStyle:PFActionButtonStyleNormal];
        [configuration setTitle:NSLocalizedString(@"Log In with Facebook", @"Log In with Facebook") forButtonStyle:PFActionButtonStyleWide];
        
        facebookButton = [[PFActionButton alloc] initWithConfiguration:configuration buttonStyle:PFActionButtonStyleNormal];
        
        facebookButton.frame = CGRectMake(0, 0, self.facebookView.frame.size.width, self.facebookView.frame.size.height);
        [self.facebookView addSubview:facebookButton];
        [facebookButton addTarget:self action:@selector(_loginWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (showTwitterButton && !twitterButton && layoutCount == 2) {
        PFActionButtonConfiguration *twitterConfig = [[PFActionButtonConfiguration alloc] initWithBackgroundImageColor:[PFColor twitterButtonBackgroundColor]
                                                                                                                 image:[PFImage imageNamed:@"twitter_icon.png"]];
        
        [twitterConfig setTitle:NSLocalizedString(@"Twitter", @"Twitter") forButtonStyle:PFActionButtonStyleNormal];
        [twitterConfig setTitle:NSLocalizedString(@"Log In with Twitter", @"Log In with Twitter") forButtonStyle:PFActionButtonStyleWide];

        twitterButton = [[PFActionButton alloc] initWithConfiguration:twitterConfig buttonStyle:PFActionButtonStyleNormal];
        
        twitterButton.frame = CGRectMake(0, 0, self.twitterView.frame.size.width, self.twitterView.frame.size.height);
        [self.twitterView addSubview:twitterButton];
        [twitterButton addTarget:self action:@selector(_loginWithTwitter) forControlEvents:UIControlEventTouchUpInside];
    }

    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    
    maskLayer.colors = [NSArray arrayWithObjects:(__bridge id)outerColor,
                        (__bridge id)innerColor, (__bridge id)innerColor, (__bridge id)outerColor, nil];
    maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.05],
                           [NSNumber numberWithFloat:0.8],
                           [NSNumber numberWithFloat:1.0], nil];
    
    maskLayer.bounds = CGRectMake(0, 0,
                                  self.containerView.frame.size.width,
                                  self.containerView.frame.size.height);
    maskLayer.anchorPoint = CGPointZero;
    
    self.containerView.layer.mask = maskLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    showFacebookButton = YES;
    showTwitterButton = YES;
    layoutCount = 0;
    
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) showFacebookButton = NO;
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) showTwitterButton = NO;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    [self.tableView registerClass:[LoadingTableViewCell class] forCellReuseIdentifier:@"loadingCell"];
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40) duration:8.0f andFadeLength:10.0f];
    titleLabel.text = @"Friends";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    ProfileNavButton *profile = [[ProfileNavButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    profile.delegate = self;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:profile];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.searchBar.delegate = self;
    self.searchBar.tag = 101;

    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAcceptRequestInSearch) name:@"didAcceptRequestInSearch" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [[self transitionCoordinator] animateAlongsideTransition:^(id context) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }completion:^(id context) {
            if ([context isCancelled]) {
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toFriendsWatchlist"]) {
        WatchlistsViewController *watchlist = segue.destinationViewController;
        watchlist.friendViewing = selectedUser;
    }
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
