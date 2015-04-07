//
//  WatchlistsViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "WatchlistsViewController.h"
#import "PFLoginBlocks.h"
#import "LoadingTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "CountTableViewCell.h"

@interface WatchlistsViewController ()

@end

@implementation WatchlistsViewController

const float heightAbvHeader = 45.0f;

@synthesize tableView;
@synthesize movies;
@synthesize segmentedControl;
@synthesize titleLabel;
@synthesize friendViewing;
@synthesize seenMovies;

- (void)gotoMovie:(TMDBMovie *)movie {
    selectedMovie = movie;
    [self performSegueWithIdentifier:@"directToMovie" sender:self];
}

- (IBAction)sortByChanged:(id)sender {

    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(0, 0);
    
//    [self sortMoviesAccordingly];
//    [self changeSeparatorsAccordingly];
//    mostDemand = 0;
//    [self.tableView reloadData];
//    self.tableView.contentOffset = CGPointMake(0, 0);
//    
//    if ([self currentSortType] == sortTypeDemand) {
//        for (UITableViewCell *cell in [self.tableView visibleCells]) {
//            if ([[cell class] isSubclassOfClass:[WatchlistTableViewCell class]]) {
//                [(WatchlistTableViewCell *)cell animateDemandBarIn];
//            }
//        }
//    } else if ([self currentSortType] == sortTypeTomatoes) {
//        for (UITableViewCell *cell in [self.tableView visibleCells]) {
//            if ([[cell class] isSubclassOfClass:[WatchlistTableViewCell class]]) {
//                [(WatchlistTableViewCell *)cell animateTomatometerIn];
//            }
//        }
//    }
}

- (WatchlistType)currentWatchlistType {
    return (WatchlistType)self.segmentedControl.selectedSegmentIndex;
}

- (void)didAddMovieToWatchlist:(NSNotification *)notification {
    [self loadData];
}

- (void)didAddMovieToSeen:(NSNotification *)notification {
    [self tapSeen];
}

- (void)tapSeen {
    [[ParseHelper sharedInstance] moviesSeenForUser:(friendViewing)?friendViewing:[PFUser currentUser] success:^(NSArray *seen) {
        seenMovies = seen;
        [self sortMoviesAccordingly];
        [self.tableView reloadData];
    }error:^(NSError *error) {
        
    }];
}

#pragma mark - Private

- (void)loadData {
    NSLog(@"LOAD DATA CALLED");
    PFUser *userViewing = (friendViewing)?friendViewing:[PFUser currentUser];
    if (userViewing) {
        mostDemand = 0;
        [[ParseHelper sharedInstance] moviesForUser:userViewing success:^(NSArray *results) {
            movies = results;
            hasLoadedWatchlist = YES;
            [self sortMoviesAccordingly];
            [self.tableView reloadData];
        }error:^(NSError *error) {
            
        }];
        [[ParseHelper sharedInstance] moviesSeenForUser:userViewing success:^(NSArray *results) {
            seenMovies = results;
            [self sortMoviesAccordingly];
            [self.tableView reloadData];
        }error:^(NSError *error) {
            
        }];
    }
    if (friendViewing) {
        [[ParseHelper sharedInstance] moviesForUser:[PFUser currentUser] success:^(NSArray *results) {
            canShowWatchlist = YES;
            [self.tableView reloadData];
        }error:^(NSError *error) {
            
        }];
        
        [[ParseHelper sharedInstance] moviesSeenForUser:[PFUser currentUser] success:^(NSArray *results) {
            canShowSeen = YES;
            [self.tableView reloadData];
        }error:^(NSError *error) {
            
        }];
    }
}

- (void)sortMoviesAccordingly {
    ComparisonBlock releaseDataComparator = ^NSComparisonResult(PFMovie *a, PFMovie *b) {
        NSDate *dateA = [[TMDBHelper sharedInstance] dateFromString:a.releaseDate];
        NSDate *dateB = [[TMDBHelper sharedInstance] dateFromString:b.releaseDate];
        
        if (dateA && dateB) {
            return [dateB compare:dateA];
        } else if (dateA) {
            return NSOrderedAscending;
        } else if (dateB) {
            return NSOrderedDescending;
        } else {
            if (a.releaseDate && a.releaseDate.length > 3 && b.releaseDate && b.releaseDate.length > 3) {
                return [[b.releaseDate substringToIndex:4] compare:[a.releaseDate substringToIndex:4]];
            } else if (a.releaseDate && a.releaseDate.length > 3) {
                return NSOrderedAscending;
            } else if (b.releaseDate && b.releaseDate.length > 3) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }
//        return [[[TMDBHelper sharedInstance] dateFromString:b.releaseDate] compare:[[TMDBHelper sharedInstance] dateFromString:a.releaseDate]];
    };
    
    ComparisonBlock locationComparator = ^NSComparisonResult(PFMovie *a, PFMovie *b) {
        return [a.title compare:b.title];
    };
    
    ComparisonBlock tomatoesComparator = ^NSComparisonResult(PFMovie *a, PFMovie *b) {
        return [b.rottenTomatoesScore floatValue] - [a.rottenTomatoesScore floatValue];
    };
    
    ComparisonBlock demandComparator = ^NSComparisonResult(PFMovie *a, PFMovie *b) {
        return b.userCount - a.userCount;
    };
    
    ComparisonBlock comparator;
    switch ([self currentSortType]) {
        case sortTypeRelease: comparator = releaseDataComparator; break;
        case sortTypeLocation: comparator = locationComparator; break;
        case sortTypeTomatoes: comparator = tomatoesComparator; break;
        case sortTypeDemand: comparator = demandComparator; break;
        default: break;
    }
    
    movies = [movies sortedArrayUsingComparator:comparator];
    seenMovies = [seenMovies sortedArrayUsingComparator:comparator];
}

- (void)changeSeparatorsAccordingly {
    if ([self currentSortType] == sortTypeTomatoes || [self currentSortType] == sortTypeDemand) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}

- (SortType)currentSortType {
    return sortTypeRelease;
//    return (int)self.segmentedControl.selectedSegmentIndex;
}

- (int)mostDemand {
    if (mostDemand == 0) {
        for (PFMovie *movie in movies) {
            if (movie.userCount > mostDemand) {
                mostDemand = movie.userCount;
            }
        }
    }
    
    return mostDemand;
}

#pragma mark - Friends

- (void)friendsTap {
    [self performSegueWithIdentifier:@"toFriends" sender:self];
}

- (void)tapFriendPicture {
    NSLog(@"tap friend picture");
    profilePicture.alpha = 0.0f;
    [self performSegueWithIdentifier:@"toFriendPicture" sender:self];
}

- (void)dismissedFriendPictureViewController {
    profilePicture.alpha = 1.0f;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return movies.count + 2;
//    } else if (section == 1) {
//        if (seenMovies.count == 0) {
//            return 0;
//        } else {
//            return seenMovies.count + 1;
//        }
//    }
    if ([self currentWatchlistType] == watchlist) {
        return movies.count + 1;
    } else if ([self currentWatchlistType] == seen) {
        return seenMovies.count + 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
//    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && movies.count == 0 && !hasLoadedWatchlist) {
        //loading cell
        LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
        [cell start];
        return cell;
    }
    if (indexPath.section == 0 && [self currentWatchlistType] == watchlist && indexPath.row == movies.count) {
        //Movie Count Cell
        CountTableViewCell *countCell = [tableView dequeueReusableCellWithIdentifier:@"countCell"];
//        NSLog(@)
        [countCell.countLabel setText:[NSString stringWithFormat:@"%i Movie%@", (int)movies.count, ((int)movies.count == 1)?@"":@"s"]];
        return countCell;
    } else if (indexPath.section == 0 && [self currentWatchlistType] == seen && indexPath.row == seenMovies.count) {
        //Seen Movie Count Cell
        CountTableViewCell *countCell = [tableView dequeueReusableCellWithIdentifier:@"countCell"];
        [countCell.countLabel setText:[NSString stringWithFormat:@"%i Movie%@ Seen", (int)seenMovies.count, (seenMovies.count == 1)?@"":@"s"]];
        return countCell;
    }
//    if (indexPath.section == 0 && indexPath.row == movies.count + 1) {
//        //blank cell
//        UITableViewCell *blankCell = [tableView1 dequeueReusableCellWithIdentifier:@"blankCell"];
//        blankCell.backgroundColor = [UIColor clearColor];
//        blankCell.contentView.backgroundColor = [UIColor clearColor];
//        return blankCell;
//    }
    
    NSString *identifier;
//    switch ([self currentSortType]) {
//        case sortTypeRelease: identifier = (friendViewing)?@"releaseFriendCell":@"releaseCell";break;
//        case sortTypeDemand: identifier = (friendViewing)?@"demandFriendCell":@"demandCell"; break;
//        case sortTypeTomatoes: identifier = (friendViewing)?@"tomatoesFriendCell":@"tomatoesCell"; break;
//        case sortTypeLocation: identifier = @"locationCell"; break;
//        default: break;
//    }
    switch ([self currentWatchlistType]) {
        case watchlist: identifier = (friendViewing)?@"releaseFriendCell":@"releaseCell"; break;
        case seen: identifier = @"ratingCell"; break;
        default:
            break;
    }
    
    WatchlistTableViewCell *cell = (WatchlistTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.sortType = [self currentSortType];
    cell.mostDemand = [self mostDemand];
    
    if ([self currentWatchlistType] == watchlist) {
        cell.movie = movies[indexPath.row];
    } else if ([self currentWatchlistType] == seen) {
        [cell setRating:[[(friendViewing)?friendViewing:[PFUser currentUser] objectForKey:@"ratings"] objectForKey:[seenMovies[indexPath.row] tmdbId]]];
        cell.movie = seenMovies[indexPath.row];
    }
//    if (indexPath.section == 0) {
//        cell.movie = movies[indexPath.row];
//    } else if (indexPath.section == 1) {
//        cell.movie = seenMovies[indexPath.row];
//    }
    if (friendViewing) {
        [self setCorrectStatusOnCell:cell movie:cell.movie];
    }
    
    return cell;
}

- (void)setCorrectStatusOnCell:(WatchlistTableViewCell *)cell movie:(PFMovie *)movie {
    cell.statusButton.status = movieAdd;
    if (canShowWatchlist) {
        [[ParseHelper sharedInstance] userHasMovieId:movie.tmdbId success:^(BOOL has) {
            if (has) {
                cell.statusButton.status = movieOnWatchlist;
            }
        }error:^(NSError *error) {
            
        }];
    }
    if (canShowSeen) {
        [[ParseHelper sharedInstance] userHasSeenMovieId:movie.tmdbId success:^(BOOL has) {
            if (has) {
                cell.statusButton.status = movieSeen;
            }
        }error:^(NSError *error) {
            
        }];
    }
}

- (UIView *)tableView:(UITableView *)tableView1 viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header;
    
    header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    if (![header viewWithTag:101]) {
        float headerHeight = 50.0f;
        header.contentView.backgroundColor = [UIColor clearColor];
        
        header.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, headerHeight)]; //30
        header.backgroundView.backgroundColor = UIColorFromRGB(0x1e2227);
        header.backgroundView.alpha = 0.0f;
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, -heightAbvHeader, self.tableView.frame.size.width, headerHeight+heightAbvHeader)];
        background.backgroundColor = UIColorFromRGB(0x1e2227);
        background.alpha = .7f;
        [header.contentView addSubview:background];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.frame.size.width - 20, headerHeight)];
        label.textColor = [UIColor whiteColor];
        label.tag = 101;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.text = (friendViewing)?[NSString stringWithFormat:@"Movies %@ Has Seen", [[friendViewing[@"name"] componentsSeparatedByString:@" "] objectAtIndex:0]]:@"Movies I've Seen";
        [header.contentView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        imageView.center = CGPointMake(self.tableView.frame.size.width/2, -heightAbvHeader/2);
        imageView.tag = 102;
        imageView.image = [UIImage imageNamed:@"seen_large"];
        [header.contentView addSubview:imageView];
        
        UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        leftImage.tag = 103;
        leftImage.image = [UIImage imageNamed:@"seen_large"];
        leftImage.center = CGPointMake(24, headerHeight/2);
        if (pastSeenHeader) {
            leftImage.alpha = 1.0f;
            leftImage.transform = CGAffineTransformIdentity;
        } else {
            leftImage.alpha = 0.0f;
            leftImage.transform = CGAffineTransformMakeTranslation(0, -30);
        }
        [header.contentView addSubview:leftImage];
    }

    
    UIImageView *leftImage = (UIImageView *)[header viewWithTag:103];
    if (pastSeenHeader) {
        leftImage.alpha = 1.0f;
        leftImage.transform = CGAffineTransformIdentity;
    } else {
        leftImage.alpha = 0.0f;
        leftImage.transform = CGAffineTransformMakeTranslation(0, -30);
    }
    
    seenHeader = header;
    
    return header;
//    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
//    
//    if (![header viewWithTag:101]) {
//        header.backgroundView = [[UIView alloc] init];
//        header.backgroundView.backgroundColor = [UIColor clearColor];
//        header.backgroundColor = [UIColor clearColor];
//        
//        UIView *button = [[UIView alloc] initForAutoLayout];
//        button.tag = 101;
//        button.backgroundColor = UIColorFromRGB(grayColor);
//        button.layer.cornerRadius = 5.0f;
//        [header.contentView addSubview:button];
//        
//        [button autoSetDimension:ALDimensionWidth toSize:200 relation:NSLayoutRelationGreaterThanOrEqual];
//        [button autoSetDimension:ALDimensionHeight toSize:30];
//        [button autoAlignAxis:ALAxisVertical toSameAxisOfView:button.superview];
//        [button autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:button.superview withOffset:-5.0f];
//        
//        UIView *container = [[UIView alloc] initForAutoLayout];
//        [button addSubview:container];
//        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
//            [container autoCenterInSuperview];
//            [container autoSetContentHuggingPriorityForAxis:ALAxisHorizontal];
//            [container autoSetContentHuggingPriorityForAxis:ALAxisVertical];
//            [container autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
//            [container autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
//        }];
//        
//        [UIView autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
//            [container autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:container.superview withOffset:5.0f relation:NSLayoutRelationGreaterThanOrEqual];
//            [container autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:container.superview withOffset:-5.0f relation:NSLayoutRelationGreaterThanOrEqual];
//        }];
//        
//        UIImageView *imageView = [[UIImageView alloc] initForAutoLayout];
//        imageView.image = [UIImage imageNamed:@"seen"];
//        [container addSubview:imageView];
//        
//        UILabel *label = [[UILabel alloc] initForAutoLayout];
//        label.text = (friendViewing)?[NSString stringWithFormat:@"Movies %@ Has Seen", [[friendViewing[@"name"] componentsSeparatedByString:@" "] objectAtIndex:0]]:@"Movies I've Seen";
//        label.textColor = [UIColor whiteColor];
//        label.font = [UIFont systemFontOfSize:15.0f];
//        [container addSubview:label];
//        
//        [imageView autoSetDimension:ALDimensionHeight toSize:15.0f];
//        [imageView autoSetDimension:ALDimensionWidth toSize:15.0f];
//        [imageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:imageView.superview];
//        [imageView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:label withOffset:-5.0f];
//        [imageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:imageView.superview];
//        
//        [label autoAlignAxis:ALAxisHorizontal toSameAxisOfView:label.superview];
//        [label autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:label.superview];
//        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSeen)];
//        [header addGestureRecognizer:tap];
//    }
//    
//    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 50;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == movies.count + 1 && indexPath.section == 0) {
//        return heightAbvHeader;
//    }
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self currentWatchlistType] == watchlist && indexPath.row < movies.count) {
        selectedPFMovie = movies[indexPath.row];
        selectedMovie = [ParseConverter tmdbMovieForPFMovie:movies[indexPath.row]];
        [self performSegueWithIdentifier:@"directToMovie" sender:self];
    } else if ([self currentWatchlistType] == seen && indexPath.row < seenMovies.count) {
        selectedPFMovie = seenMovies[indexPath.row];
        selectedMovie = [ParseConverter tmdbMovieForPFMovie:seenMovies[indexPath.row]];
        [self performSegueWithIdentifier:@"directToMovie" sender:self];
    }

}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0 && indexPath.row >= movies.count) {
//        return NO;
//    } else if (indexPath.section == 1 && indexPath.row == seenMovies.count) {
//        return NO;
//    }
    if ([self currentWatchlistType] == watchlist && indexPath.row >= movies.count) {
        return NO;
    } else if ([self currentWatchlistType] == seen && indexPath.row >= seenMovies.count) {
        return NO;
    }
    
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    float beginOffset = cell.frame.origin.y - heightAbvHeader - 50; //header height
    float endOffset = beginOffset + heightAbvHeader;

    if (beginOffset >= 0 && seenHeader) {
        UIImageView *leftImage = (UIImageView *)[seenHeader viewWithTag:103];

        if (scrollView.contentOffset.y <= beginOffset) {
            //before
            leftImage.alpha = 0.0f;
            leftImage.transform = CGAffineTransformMakeTranslation(0, -30);
            pastSeenHeader = NO;
        } else if (scrollView.contentOffset.y > beginOffset && scrollView.contentOffset.y < endOffset) {
            //animate
            float percentage = (scrollView.contentOffset.y - beginOffset)/(endOffset - beginOffset);
            NSLog(@"animate percent: %f", percentage);
            leftImage.alpha = percentage;
            leftImage.transform = CGAffineTransformMakeTranslation(0, -30+30*percentage);
        } else {
            //after
            leftImage.alpha = 1.0f;
            leftImage.transform = CGAffineTransformIdentity;
            pastSeenHeader = YES;
        }
    }
}

#pragma mark - UIViewController

- (void)viewDidLayoutSubviews {
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
    
//    [self makeTableFooter];
}

- (void)makeTableFooter {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    
    UIView *button = [[UIView alloc] initForAutoLayout];
    button.backgroundColor = UIColorFromRGB(grayColor);
    button.layer.cornerRadius = 5.0f;
    [self.tableView.tableFooterView addSubview:button];
    
    [button autoSetDimension:ALDimensionWidth toSize:200 relation:NSLayoutRelationGreaterThanOrEqual];
    [button autoSetDimension:ALDimensionHeight toSize:30];
    [button autoAlignAxis:ALAxisVertical toSameAxisOfView:button.superview];
    [button autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:button.superview withOffset:-15.0f];
    
    UIView *container = [[UIView alloc] initForAutoLayout];
    [button addSubview:container];
    [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
        [container autoCenterInSuperview];
        [container autoSetContentHuggingPriorityForAxis:ALAxisHorizontal];
        [container autoSetContentHuggingPriorityForAxis:ALAxisVertical];
        [container autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
        [container autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
    }];
    
    [UIView autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
        [container autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:container.superview withOffset:5.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [container autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:container.superview withOffset:-5.0f relation:NSLayoutRelationGreaterThanOrEqual];
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initForAutoLayout];
    imageView.image = [UIImage imageNamed:@"seen"];
    [container addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initForAutoLayout];
    label.text = (friendViewing)?[NSString stringWithFormat:@"Movies %@ Has Seen", [[friendViewing[@"name"] componentsSeparatedByString:@" "] objectAtIndex:0]]:@"Movies I've Seen";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15.0f];
    [container addSubview:label];
    
    [imageView autoSetDimension:ALDimensionHeight toSize:15.0f];
    [imageView autoSetDimension:ALDimensionWidth toSize:15.0f];
    [imageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:imageView.superview];
    [imageView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:label withOffset:-5.0f];
    [imageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:imageView.superview];
    
    [label autoAlignAxis:ALAxisHorizontal toSameAxisOfView:label.superview];
    [label autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:label.superview];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSeen)];
    [self.tableView.tableFooterView addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.transitioningDelegate = nil;
    self.navigationController.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
//    if let indexPath = tableView.indexPathForSelectedRow() {
//        
//        transitionCoordinator()?.animateAlongsideTransition({ context in
//            
//            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
//            
//        }, completion: { context in
//            
//            if context.isCancelled() {
//                self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
//            }
//        })
//    }
    NSIndexPath *indexPath = tableView.indexPathForSelectedRow;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    if (friendViewing) {
//        self.navigationItem.rightBarButtonItem = nil;
        profilePicture = [[ProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        profilePicture.user = friendViewing;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFriendPicture)];
        [profilePicture addGestureRecognizer:tap];
        
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:profilePicture];
        self.navigationItem.rightBarButtonItem = right;
    } else {
        UIButton *friendsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 31.2, 20)];
        [friendsButton addTarget:self action:@selector(friendsTap) forControlEvents:UIControlEventTouchUpInside];
        [friendsButton setImage:[UIImage imageNamed:@"friendsIcon"] forState:UIControlStateNormal];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:friendsButton];
        self.navigationItem.leftBarButtonItem = item;
    }
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"footer"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    [self.tableView registerClass:[LoadingTableViewCell class] forCellReuseIdentifier:@"loadingCell"];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 8);
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40) duration:8.0f andFadeLength:10.0f];
    NSString *title = @"My Screen";
    if (friendViewing) {
        if ([friendViewing objectForKey:@"name"] && ![[friendViewing objectForKey:@"name"] isEqualToString:@""]) {
            NSString *name = [[(NSString*)[friendViewing objectForKey:@"name"] componentsSeparatedByString:@" "] objectAtIndex:0];
            title = [NSString stringWithFormat:@"%@'s Screen", name];
        } else {
            title = @"Friend's Screen";
        }
    }
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddMovieToWatchlist:) name:parseDidAddMovieToWatchlistNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddMovieToSeen:) name:parseDidAddMovieToSeenNotification object:nil];
    
    segmentedControl.tintColor = UIColorFromRGB(blueColor);
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor] } forState:UIControlStateSelected];
    [self.segmentedControl setSelectedSegmentIndex:0];
    
    [self loadData];
        
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"hasShownVideo"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"hasShownVideo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self playVideo];
    } else if (![PFUser currentUser]) {
        [[LocationHelper sharedInstance] requestAuthorizationIfNeeded];
        [self showLogin];
    } else {
        [[LocationHelper sharedInstance] requestAuthorizationIfNeeded];
        //Testing
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhighlightRow) name:overrideRowHighlightNotification object:nil];
}

- (void)unhighlightRow {
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
    }
}

- (void)playVideo {
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayback
     error: nil];
    NSURL *movieUrl = [[NSBundle mainBundle] URLForResource:@"BetaIntroVideoFinal" withExtension:@"mp4"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:movieUrl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    
    moviePlayer = [AVPlayer playerWithPlayerItem:item]; //
    
    movieLayer = [AVPlayerLayer layer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [movieLayer setPlayer:moviePlayer];
    [movieLayer setFrame:self.view.bounds];
    [movieLayer setBackgroundColor:[UIColor blackColor].CGColor];
    [movieLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
//    [movieLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.tabBarController.view.userInteractionEnabled = NO;
    [self.tabBarController.view.layer addSublayer:movieLayer];
    
    [moviePlayer play];
    
    cancelMovieView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 103, self.tabBarController.view.superview.frame.size.height - 50, 103, 50)];
//    cancelMovieView.backgroundColor = [UIColor orangeColor];
    
    UIImageView *cancel = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    cancel.image = [UIImage imageNamed:@"add"];
    cancel.transform = CGAffineTransformMakeRotation(M_PI*.25);
    cancel.alpha = .5f;
    cancel.center = CGPointMake(cancelMovieView.frame.size.width/2, cancelMovieView.frame.size.height/2-4);
    [cancelMovieView addSubview:cancel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoFinished)];
    [cancelMovieView addGestureRecognizer:tap];
    [self.tabBarController.view.superview addSubview:cancelMovieView];
}

- (void)videoFinished {
    self.tabBarController.view.userInteractionEnabled = YES;
    [moviePlayer pause];
    [movieLayer removeFromSuperlayer];
    [cancelMovieView removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    if (![PFUser currentUser]) {
        [[LocationHelper sharedInstance] requestAuthorizationIfNeeded];
        [self showLogin];
    }
}

- (void)showLogin {
    NSLog(@"show login");
    [self.navigationController popToRootViewControllerAnimated:YES];
    PFLoginBlocks *blocks = [[PFLoginBlocks alloc] init];
    blocks.didLogInUser = ^void(PFUser *user) {
        NSLog(@"did log in user");
        [self loadData];
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
        [[PFInstallation currentInstallation] saveInBackground];
    };
    
    [[ParseHelper sharedInstance] showLoginOnViewController:self blocks:blocks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"directToMovie"]) {
        MovieViewController *destination = (MovieViewController*)segue.destinationViewController;
        destination.movie = selectedMovie;
        destination.pfMovie = selectedPFMovie;
    } else if ([segue.identifier isEqualToString:@"toFriendPicture"]) {
        FriendPictureViewController *destination = (FriendPictureViewController *)segue.destinationViewController;
        destination.user = friendViewing;
        destination.startingPictureRect = [self.view convertRect:profilePicture.frame fromView:profilePicture.superview];
        destination.delegate = self;
    }
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
