//
//  ShowtimesViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "ShowtimesViewController.h"
#import "ParseHelper.h"
#import "LoadingTableViewCell.h"
#import "TheaterViewController.h"
#import "MWPopoverView.h"
#import "RadiusSelectorView.h"

dispatch_queue_t backgroundQueue;

@interface ShowtimesViewController () {
    RadiusSelectorView *radiusSelector;
}

@end

@implementation ShowtimesViewController

const float heightAboveHeader = 45.0f;

@synthesize tableView;
@synthesize radiusView;
//@synthesize locationLabel;

#pragma mark - Load Data

- (void)loadData {
    float radius = [[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue];
    [[OnConnectHelper sharedInstance] showtimesInRadiusOfCurrentLocation:radius success:^(NSArray *results) {
        playingNearby = results;
        dispatch_async(backgroundQueue, ^{
            [self sortPlayingNearby];
        });
        [self loadTheaters];
    }error:^(NSError *error) {
        NSLog(@"ERROR getting showtimes");
        erroredSections[0] = @1;
        erroredSections[1] = @1;
        [self showCorrectErrors];
    }];
    
//    [[LocationHelper sharedInstance] getLocationUserWants:^(CLLocation *location) {
//        [[ParseHelper sharedInstance] mostPopularAroundCoordinate:location radius:radius limit:20 success:^(NSArray *results) {
//            mostPopular = results;
//            NSLog(@"most popular count: %i", (int)results.count);
//            [self filterTrending];
//            loadedSections[2] = @1;
//            [self.tableView reloadData];
//        }error:^(NSError *error) {
//            erroredSections[2] = @1;
//            [self showCorrectErrors];
//        }];
//    }error:^(NSError *error) {
//        erroredSections[2] = @1;
//        [self showCorrectErrors];
//    }];
}

- (void)showCorrectErrors {
    if ([self sortType] == byMovie) {
        LoadingTableViewCell *topLoading = (LoadingTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        [topLoading goToErrorRetry];
        topLoading.retryHandler = ^{
            [self reload];
        };
        
//        LoadingTableViewCell *bottomLoading = (LoadingTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
//        [bottomLoading goToErrorRetry];
//        bottomLoading.retryHandler = ^{
//            [self reload];
//        };
    } else {
        LoadingTableViewCell *loading = (LoadingTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [loading goToErrorRetry];
        loading.retryHandler = ^{
            [self reload];
        };
    }
}

- (void)reload {
    loadedSections = [NSMutableArray arrayWithArray:@[@0, @0, @0]];
    erroredSections = [NSMutableArray arrayWithArray:@[@0, @0, @0]];
    doneLoadingTheaters = NO;
    playingNearby = nil;
    playingOnWatchlist = nil;
    mostPopular = nil;
    theaters = nil;
    [self.tableView reloadData];
    [self loadData];
    [self updateLocationLabel];
}

- (void)loadTheaters {
    float radius = [[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue];
    NSLog(@"START THEATERS");
    [[OnConnectHelper sharedInstance] theaterDetailsInRadiusOfCurrentLocation:radius success:^(NSArray *theaterResults) {
        theaters = theaterResults;
        dispatch_async(backgroundQueue, ^{
            [[OnConnectHelper sharedInstance] showTimesForTheatersNearby:^(NSDictionary *showtimesTheaters) {
                showtimesForTheaters = [NSMutableDictionary dictionaryWithDictionary:showtimesTheaters];
                doneLoadingTheaters = YES;
                [self filterTheatersForShowtimes];
                if ([self sortType] == byTheater) {
                    NSLog(@"should reload table view for theaters: %i", (int)theaters.count);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }error:^(NSError *error) {
                
            }];
        });
        
    }error:^(NSError *error) {
        
    }];
//    NSLog(@"START THEATERS");
//    [[OnConnectHelper sharedInstance] showtimesInRadiusOfCurrentLocation:radius success:^(NSArray *showtimes) {
//        NSLog(@"theater showtimes: %i", (int)showtimes.count);
//        [[OnConnectHelper sharedInstance] theaterDetailsInRadiusOfCurrentLocation:radius success:^(NSArray *theaterResults) {
//            NSLog(@"done loading theaters: %i", (int)theaterResults.count);
//            theaters = theaterResults;
//            dispatch_async(backgroundQueue, ^{
//                [self filterTheaters];
//                doneLoadingTheaters = YES;
//                if ([self sortType] == byTheater) {
//                    NSLog(@"should reload table view for theaters: %i", (int)theaters.count);
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.tableView reloadData];
//                    });
//                }
//            });
//            
//            
//        }error:^(NSError *error) {
//            NSLog(@"error loading theater details");
//        }];
//    }error:^(NSError *error) {
//        NSLog(@"error loading theaters");
//    }];
}

- (void)filterTheatersForShowtimes {
    theaters = [theaters filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(OCTheater *theater, NSDictionary *bindings) {
        return ([showtimesForTheaters objectForKey:theater.theaterId] && [[showtimesForTheaters objectForKey:theater.theaterId] count] > 0);
    }]];
}

- (void)filterTheaters {
    NSMutableArray *newTheaters = [NSMutableArray array];
    showtimesForTheaters = [NSMutableDictionary dictionary];
    for (OCTheater *theater in theaters) {
        [[OnConnectHelper sharedInstance] showTimesForTheater:theater success:^(NSArray *showtimes) {
            NSLog(@"%i showings for theater: %@", (int)showtimes.count, theater.name);
            if (showtimes && showtimes.count > 0) {
                [newTheaters addObject:theater];
                [showtimesForTheaters setObject:showtimes forKey:theater.theaterId];
            }
        }error:^(NSError *error) {
            
        }];
    }
    
    theaters = [NSArray arrayWithArray:newTheaters];
}

- (void)filterTrending {
    mostPopular = [mostPopular filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *obj, NSDictionary *bindings) {
        if ([obj objectForKey:@"movie"]) {
            return YES;
        } else {
            return NO;
        }
    }]];
}

#pragma mark - Private

- (void)sortPlayingNearby {
    NSMutableArray *newPlayingNow = [NSMutableArray array];
    NSMutableArray *watchlist = [NSMutableArray array];
    
    [[ParseHelper sharedInstance] getWatchlistIfNeeded:^{
        [[ParseHelper sharedInstance] getSeenIfNeeded:^{
            NSArray *watch = [[ParseHelper sharedInstance] userHasOCMovies:playingNearby state:onWatchlist];
            
            NSMutableDictionary *rootIds = [NSMutableDictionary dictionary];
            for (OCMovie *mov in watch) {
                if (![rootIds objectForKey:mov.rootId]) {
                    [watchlist addObject:mov];
                }
                [rootIds setObject:@1 forKey:mov.rootId];
            }
            for (OCMovie *mov in playingNearby) {
                if (![rootIds objectForKey:mov.rootId]) {
                    [newPlayingNow addObject:mov];
                    [rootIds setObject:@1 forKey:mov.rootId];
                }
            }
//            for (OCMovie *movie in playingNearby) {
//
//                if ([[ParseHelper sharedInstance] userHasOCMovie:movie state:onWatchlist] && ![self containsRootOCMovie:@[newPlayingNow, seen, watchlist] movie:movie]) {
//                    [watchlist addObject:movie];
//                } else if ([[ParseHelper sharedInstance] userHasOCMovie:movie state:onSeen] && ![self containsRootOCMovie:@[newPlayingNow, seen, watchlist] movie:movie]) {
//                    [seen addObject:movie];
//                } else if (![self containsRootOCMovie:@[newPlayingNow, seen, watchlist] movie:movie]) {
//                    [newPlayingNow addObject:movie];
//                }
//            }

            playingNearby = [NSArray arrayWithArray:newPlayingNow];
            playingOnWatchlist = [NSArray arrayWithArray:watchlist];
            loadedSections[0] = @1;
            loadedSections[1] = @1;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }error:^(NSError *error) {
        }];
    }error:^(NSError *error) {
    }];
}

- (BOOL)containsRootOCMovie:(NSArray *)arrays movie:(OCMovie *)movie {
    BOOL contains = NO;
    
    for (NSArray *array in arrays) {
        for (OCMovie *mov in array) {
            if ([mov.rootId isEqualToString:movie.rootId]) {
                contains = YES;
            }
        }
    }
    
    return contains;
}

- (IBAction)sortingChanged:(id)sender {
    if ([self sortType] == byTheater) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 13, 0, 8);
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 8);
    }
    
    self.tableView.contentOffset = CGPointMake(0, 0);
    
    [self.tableView reloadData];
}

- (SortShowtimesType)sortType {
    return (SortShowtimesType)self.segmentedControl.selectedSegmentIndex;
}

- (void)tapRadius {
    MWPopoverView *popover = [MWPopoverView popoverWithSize:CGSizeMake(280, 220) inView:self.tabBarController.view];
    popover.popoverPosition = mwPopoverPositionBottom;
    popover.background = UIColorFromRGB(0x21252A);
    
    if (!radiusSelector) {
        radiusSelector = [[RadiusSelectorView alloc] initWithFrame:CGRectMake(0, 0, 280, 220)];
    } else {
        [radiusSelector update];
    }
    __weak id weakSelf = self;
    radiusSelector.changeHandler = ^{
        [[OnConnectHelper sharedInstance] voidShowtimes];
        [weakSelf reload];
        [popover hideWithDuration:.3f animationBlock:^{
            popover.alpha = 0.0f;
        }];
    };
    radiusSelector.pickLocationHandler = ^{
        [weakSelf performSegueWithIdentifier:@"toLocationPickerFromShowtimes" sender:weakSelf];
        [popover hideWithDuration:0.0f animationBlock:^{
            popover.alpha = 0.0f;
        }];
    };
    [popover.container addSubview:radiusSelector];
    
    CGPoint displayPoint = [self.tabBarController.view convertPoint:locationLabel.center fromView:locationLabel.superview];
    displayPoint.y += 10;
    [popover showFromPoint:displayPoint];

}

- (void)pickedLocationWithName:(NSString *)name coordinate:(CLLocation *)location {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"searchLatitude"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"searchLongitude"];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"searchLocationName"];
    
    [self reload];
//    [self setChangingRadius:YES];
//    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self getShowtimes];
}

- (void)pickedCurrentLocation {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"searchLatitude"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"searchLongitude"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"searchLocationName"];
    
    [self reload];
//    [self setChangingRadius:YES];
//    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self getShowtimes];
}

- (void)updateLocationLabel {
    NSString *location = @"Current Location";
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"searchLocationName"]) {
        location = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchLocationName"];
    }
    locationLabel.text = [NSString stringWithFormat:@"%.01f mi near %@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue], location];
}

- (void)tappedAddButtonOnCell:(id)cell {
    NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)cell];
    if (indexPath.section == 2) {
        NowPlayingTableViewCell *cell = (NowPlayingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.statusButton.status = statusLoading;
        [[TMDBHelper sharedInstance] movieForOCMovie:playingNearby[indexPath.row] success:^(TMDBMovie *movie) {
            if (movie) {
                justAddedMovie = YES;
                [[ParseHelper sharedInstance] addMovieToWatchlist:movie success:^(id object) {
                    if (cell.indexPath.row == indexPath.row) {
                        [cell.statusButton animateToStatus:movieOnWatchlist];
                        [self performSelector:@selector(moveCellToWatchlistSection:) withObject:indexPath afterDelay:.7f];
                    }
                }error:^(NSError *error) {
                    if (cell.indexPath.row == indexPath.row) {
                        [cell.statusButton goToFailForDuration:1.0f];
                    }
                }];
            }
        }error:^(NSError *error) {
            if (cell.indexPath.row == indexPath.row) {
                [cell.statusButton goToFailForDuration:1.0f];
            }
        }];
    }
}

- (void)moveCellToWatchlistSection:(NSIndexPath *)indexPath {
    NSMutableArray *nearby = [NSMutableArray arrayWithArray:playingNearby];
    NSMutableArray *watchlist = [NSMutableArray arrayWithArray:playingOnWatchlist];
    [watchlist addObject:[nearby objectAtIndex:indexPath.row]];
    [nearby removeObjectAtIndex:indexPath.row];
    
    playingNearby = [NSArray arrayWithArray:nearby];
    playingOnWatchlist = [NSArray arrayWithArray:watchlist];
    
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:playingOnWatchlist.count - 1 inSection:1]];
}

- (void)changedWatchlist {
    if (!justAddedMovie) {
        [self loadData];
    }
    justAddedMovie = NO;
}

- (void)friendsTap {
    [self performSegueWithIdentifier:@"toFriendsFromShowtimes" sender:self];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *movies;
    switch (section) {
        case 0: movies = [NSArray array];
        case 1: movies = playingOnWatchlist; break;
        case 2: movies = playingNearby; break;
        case 3: movies = mostPopular; break;
        default: break;
    }
    
    if ([self sortType] == byTheater && section == 0) {
        return (doneLoadingTheaters)?theaters.count:1;
    }
    if ([self sortType] == byMovie && section == 0) {
        return 1;
    }
    if ([self sortType] == byTrending) {
        if ([loadedSections[2] boolValue]) {
            return mostPopular.count;
        } else {
            return 1;
        }
    }

    if (movies.count == 0 && [loadedSections[section-1] intValue] == 0) {
        NSLog(@"loading cell should be displayed");
        return 2;
    } else {
        return movies.count + 1;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self sortType] == byMovie) {
        return 3;
    } else if ([self sortType] == byTheater) {
        return 1;
    } else if ([self sortType] == byTrending) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sortType] == byMovie) {
        NSArray *movies;
        switch (indexPath.section) {
            case 1: movies = playingOnWatchlist; break;
            case 2: movies = playingNearby; break;
            case 3: movies = mostPopular; break;
            default: break;
        }
        if (indexPath.section == 0) {
            UITableViewCell *blankCell = [tableView1 dequeueReusableCellWithIdentifier:@"blankCell"];
            blankCell.backgroundColor = [UIColor clearColor];
            blankCell.contentView.backgroundColor = [UIColor clearColor];
            return blankCell;
        }

        if (movies.count == 0 && [loadedSections[indexPath.section-1] intValue] == 0 && indexPath.row == 0) {
            //show loading
            LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
            if ([erroredSections[0] intValue] == 0) {
                [cell start];
            } else {
                [cell goToRetryUnanimated];
            }
            return cell;
        } else if (indexPath.row >= movies.count) {
            UITableViewCell *blankCell = [tableView1 dequeueReusableCellWithIdentifier:@"blankCell"];
            blankCell.backgroundColor = [UIColor clearColor];
            blankCell.contentView.backgroundColor = [UIColor clearColor];
            return blankCell;
        } else {
            NowPlayingTableViewCell *cell;
            
            if (indexPath.section == 1) {
                cell = (NowPlayingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"watchlistCell"];
            } else if (indexPath.section == 2) {
                cell = (NowPlayingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
            }
            
            if (indexPath.section == 1 || indexPath.section == 2) {
                OCMovie *movie = (indexPath.section == 1)?playingOnWatchlist[indexPath.row]:playingNearby[indexPath.row];
                cell.titleLabel.text = movie.title;
                [cell.imageView sd_setImageWithURL:[[OnConnectHelper sharedInstance] urlForImageResource:movie.posterPath size:@"h=120"] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
                
                if (indexPath.section == 2) {
                    cell.statusButton.status = movieAdd;
                }
                cell.indexPath = indexPath;
                cell.delegate = self;
            }
            if (indexPath.section == 3) {
                cell = (NowPlayingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"demandCell"];

                
                NSDictionary *obj = mostPopular[indexPath.row];
                PFMovie *movie = [obj objectForKey:@"movie"];
                
                cell.titleLabel.text = [movie displayTitle];
                if (movie.posterPath && ![movie.posterPath isEqualToString:@""]) {
                    [cell.imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"]];
                    [cell.imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
                } else {
                    cell.imageView.image = [UIImage imageNamed:@"blankPoster"];
                }
                cell.demandLabel.text = [NSString stringWithFormat:@"%i", [obj[@"count"] intValue]];
                cell.demandBarView.percentage = [[obj objectForKey:@"count"] floatValue]/[[mostPopular[0] objectForKey:@"count"] floatValue];
                
            }
            
            
            return cell;
        }
    } else if ([self sortType] == byTheater) {
        //by theater
        if (doneLoadingTheaters) {
            TheaterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"theaterCell"];
            
            OCTheater *theater = theaters[indexPath.row];
            cell.delegate = self;
            cell.showtimes = [showtimesForTheaters objectForKey:theater.theaterId];
            cell.theater = theater;
            
            
            [cell setNeedsUpdateConstraints];
            [cell updateConstraintsIfNeeded];
            
            return cell;
        } else {
            NSLog(@"loading cell");
            LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
            if ([erroredSections[1] intValue] == 0) {
                [cell start];
            } else {
                [cell goToRetryUnanimated];
            }
            return cell;
        }
        
    } else {
        //by trending
        
        if (![loadedSections[2] boolValue] && mostPopular.count == 0 && indexPath.row == 0) {
            LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
            if ([erroredSections[2] intValue] == 0) {
                [cell start];
            } else {
                [cell goToRetryUnanimated];
            }
            return cell;
        }
        
        NowPlayingTableViewCell *cell = (NowPlayingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"demandCell"];
        
        cell.separator.alpha = 0.0f;
        NSDictionary *obj = mostPopular[indexPath.row];
        PFMovie *movie = [obj objectForKey:@"movie"];
        
        cell.titleLabel.text = [movie displayTitle];
        if (movie.posterPath && ![movie.posterPath isEqualToString:@""]) {
//            [cell.imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"]];
            [cell.imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"blankPoster"];
        }
        cell.demandLabel.text = [NSString stringWithFormat:@"%i", [obj[@"count"] intValue]];
        cell.demandBarView.percentage = [[obj objectForKey:@"count"] floatValue]/[[mostPopular[0] objectForKey:@"count"] floatValue];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self sortType] == byMovie) {
        selectedPFMovie = nil;
        selectedMovie = nil;
        if (indexPath.section == 1) {
            selectedOCMovie = playingOnWatchlist[indexPath.row];
            [self performSegueWithIdentifier:@"toMovieFromShowtime" sender:self];
        }
        if (indexPath.section == 2) {
            selectedOCMovie = playingNearby[indexPath.row];
            [self performSegueWithIdentifier:@"toMovieFromShowtime" sender:self];
        }
    } else if ([self sortType] == byTheater) {
        if (indexPath.section == 0) {
            selectedTheater = theaters[indexPath.row];
            
            [self performSegueWithIdentifier:@"toTheaterFromShowtimes" sender:self];
        }
    } else if ([self sortType] == byTrending) {
        if (indexPath.row < mostPopular.count) {
            selectedOCMovie = nil;
            selectedMovie = nil;
            selectedPFMovie = mostPopular[indexPath.row][@"movie"];
            selectedMovie = [ParseConverter tmdbMovieForPFMovie:selectedPFMovie];
            [self performSegueWithIdentifier:@"toMovieFromShowtime" sender:self];
        }
    }
    

}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [self sortType] == byMovie) {
        return NO;
    }
    
    if ([self sortType] == byMovie) {
        NSArray *movies;
        switch (indexPath.section) {
            case 1: movies = playingOnWatchlist; break;
            case 2: movies = playingNearby; break;
            case 3: movies = mostPopular; break;
            default: break;
        }
        if (indexPath.row >= movies.count) {
            return NO;
        }
    }
    
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sortType] == byTheater) {
        return UITableViewAutomaticDimension;
    } else if ([self sortType] == byMovie) {
        NSArray *movies;
        switch (indexPath.section) {
            case 1: movies = playingOnWatchlist; break;
            case 2: movies = playingNearby; break;
            case 3: movies = mostPopular; break;
            default: break;
        }
        if (indexPath.section == 0) {
            //footer view
            return 45.0f;
        }
    } else if ([self sortType] == byTrending) {
        return 55.0f;
    }
    
    return 55.0f;
}

- (UIView *)tableView:(UITableView *)tableView1 viewForHeaderInSection:(NSInteger)section {
    if ([self sortType] == byMovie) {
        UITableViewHeaderFooterView *header;
        
        header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
        
        if (![header viewWithTag:101]) {
            header.contentView.backgroundColor = [UIColor clearColor];
            
            header.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)]; //30
            header.backgroundView.backgroundColor = UIColorFromRGB(0x1e2227);
            header.backgroundView.alpha = 0.0f;
            
            UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, -heightAboveHeader, self.tableView.frame.size.width, 30+heightAboveHeader)];
            background.backgroundColor = UIColorFromRGB(0x1e2227);
            background.alpha = .7f;
            [header.contentView addSubview:background];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.frame.size.width - 20, 30)];
            label.textColor = [UIColor whiteColor];
            label.tag = 101;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            [header.contentView addSubview:label];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
            imageView.center = CGPointMake(self.tableView.frame.size.width/2, -heightAboveHeader/2);
            imageView.tag = 102;
            [header.contentView addSubview:imageView];
            
            UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            leftImage.tag = 103;
            leftImage.center = CGPointMake(24, 15);
            if ([pastHeaders[section] boolValue]) {
                leftImage.alpha = 1.0f;
                leftImage.transform = CGAffineTransformIdentity;
            } else {
                leftImage.alpha = 0.0f;
                leftImage.transform = CGAffineTransformMakeTranslation(0, -30);
            }
            [header.contentView addSubview:leftImage];
        }
        
        NSString *title;
        switch (section) {
            case 1: title = ([self sortType] == byMovie) ? @"Now Playing on Watchlist" : @""; break;
            case 2: title = @"Now Playing Nearby"; break;
            case 3: title = @"Most Popular Around You"; break;
            case 4: title = @"Coming Soon"; break;
            default: title = @""; break;
        }
        [(UILabel *)[header viewWithTag:101] setText:title];
        NSString *image;
        switch (section) {
            case 1: image = @"watchlist"; break;
            case 2: image = @"location"; break;
            case 3: image = @"watchlist"; break;
            default: image = @""; break;
        }
        [(UIImageView *)[header viewWithTag:102] setImage:[UIImage imageNamed:image]];
        [(UIImageView *)[header viewWithTag:103] setImage:[UIImage imageNamed:image]];
        
        UIImageView *leftImage = (UIImageView *)[header viewWithTag:103];
        if ([pastHeaders[section] boolValue]) {
            leftImage.alpha = 1.0f;
            leftImage.transform = CGAffineTransformIdentity;
        } else {
            leftImage.alpha = 0.0f;
            leftImage.transform = CGAffineTransformMakeTranslation(0, -30);
        }
        
        movieHeaders[section] = header;
        
        return header;
    } else {
        return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self sortType] == byMovie && section != 0) {
        return 30;
    }
    return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"offset: %f", scrollView.contentOffset.y);
    if ([self sortType] == byMovie) {
        for (int i = 1; i < [self numberOfSectionsInTableView:tableView]; i++) {
            
            float beginOffset = 0;
            
            if (i != 0) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
                
                beginOffset = cell.frame.origin.y - 30 - heightAboveHeader;
            }
            
            float endOffset = beginOffset + heightAboveHeader;
            
            if (beginOffset > 0 || beginOffset == 0) {
                UITableViewHeaderFooterView *header = movieHeaders[i];
                
                if (![header isEqual:[NSNull null]]) {
                    UIImageView *leftImage = (UIImageView *)[header viewWithTag:103];
                    if (scrollView.contentOffset.y <= beginOffset) {
                        //before
                        NSLog(@"before: %i", i);
                        leftImage.alpha = 0.0f;
                        leftImage.transform = CGAffineTransformMakeTranslation(0, -30);
                        pastHeaders[i] = @0;
                    } else if (scrollView.contentOffset.y > beginOffset && scrollView.contentOffset.y < endOffset) {
                        //animate
                        float percentage = (scrollView.contentOffset.y - beginOffset)/(endOffset - beginOffset);
                        NSLog(@"animate percent: %f", percentage);
                        leftImage.alpha = percentage;
                        leftImage.transform = CGAffineTransformMakeTranslation(0, -30+30*percentage);
                    } else {
                        //after
                        NSLog(@"after: %i", i);
                        leftImage.alpha = 1.0f;
                        leftImage.transform = CGAffineTransformIdentity;
                        pastHeaders[i] = @1;
                    }
                }
            }
        }
    }
}

- (void)selectedTheater:(OCTheater *)theater {
    selectedTheater = theater;
    selectedMovieTheater = nil;
    [self performSegueWithIdentifier:@"toTheaterFromShowtimes" sender:self];
}

- (void)selectedTheater:(OCTheater *)theater movie:(OCMovie *)movie {
    selectedTheater = theater;
    selectedMovieTheater = movie;
    [self performSegueWithIdentifier:@"toTheaterFromShowtimes" sender:self];
}

#pragma mark - UIViewController

- (void)viewDidLayoutSubviews {
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    
    maskLayer.colors = [NSArray arrayWithObjects:(__bridge id)innerColor,
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
    
    CAGradientLayer *radiusMask = [CAGradientLayer layer];
    radiusMask.colors = @[(__bridge id)outerColor, (__bridge id)innerColor];
    radiusMask.locations = @[@0.0f, @.2f];
    radiusMask.bounds = CGRectMake(0, 0, radiusView.bounds.size.width, radiusView.bounds.size.height);
    radiusMask.anchorPoint = CGPointZero;
    radiusView.layer.mask = radiusMask;
    
    //    [self makeTableFooter];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    backgroundQueue = dispatch_queue_create("screen.bgqueue", NULL);
    radiusView.backgroundColor = UIColorFromRGB(0x1e2227);
    radiusView.alpha = .7f;
    
    UIButton *friendsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 31.2, 20)];
    [friendsButton addTarget:self action:@selector(friendsTap) forControlEvents:UIControlEventTouchUpInside];
    [friendsButton setImage:[UIImage imageNamed:@"friendsIcon"] forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:friendsButton];
    self.navigationItem.leftBarButtonItem = item;
    
    movieHeaders = [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null], [NSNull null], [NSNull null]]];
    pastHeaders = [NSMutableArray arrayWithArray:@[@0, @0, @0, @0]];
    
    UITapGestureRecognizer *tapRadius = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRadius)];
    [radiusView addGestureRecognizer:tapRadius];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 8);
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"footer"];
    [self.tableView registerClass:[LoadingTableViewCell class] forCellReuseIdentifier:@"loadingCell"];
    [self.tableView registerClass:[LoadingTableViewCell class] forCellReuseIdentifier:@"loadingTheater"];
    [self.tableView registerClass:[LoadingTableViewCell class] forCellReuseIdentifier:@"loadingTrending"];
    [self.tableView registerClass:[LoadingTableViewCell class] forCellReuseIdentifier:@"theaterLoadingCell"];
    [self.tableView registerClass:[TheaterTableViewCell class] forCellReuseIdentifier:@"theaterCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"blankCell"];
    
    self.segmentedControl.tintColor = UIColorFromRGB(blueColor);
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor] } forState:UIControlStateSelected];
    [self.segmentedControl setSelectedSegmentIndex:0];
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 50) duration:8.0f andFadeLength:10.0f];
    titleLabel.text = @"Showtimes";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, titleLabel.frame.size.width, 8)];
    locationLabel.font = [UIFont systemFontOfSize:10.0f];
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationItem.titleView addSubview:locationLabel];
    
    UITapGestureRecognizer *tapTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRadius)];
    self.navigationItem.titleView.userInteractionEnabled = YES;
    [self.navigationItem.titleView addGestureRecognizer:tapTitle];
    
    loadedSections = [NSMutableArray arrayWithArray:@[@0, @0, @0]];
    erroredSections = [NSMutableArray arrayWithArray:@[@0, @0, @0]];
    
//    locationLabel.textColor = UIColorFromRGB(blueColor);
    [self updateLocationLabel];
    
    [self loadData];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedWatchlist) name:parseDidAddMovieToWatchlistNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedWatchlist) name:parseDidAddMovieToSeenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhighlightRow) name:overrideRowHighlightNotification object:nil];

}

- (void)unhighlightRow {
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear");
//    if (viewHasAppeared) {
//        [self reload];
//    }
    if ([self sortType] == byTheater) {
        [self.tableView reloadData];
    }
    viewHasAppeared = YES;
    
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

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.transitioningDelegate = nil;
    self.navigationController.delegate = nil;
    self.tabBarItem.badgeValue = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toMovieFromShowtime"]) {
        MovieViewController *destination = (MovieViewController *)segue.destinationViewController;
        if (selectedOCMovie) {
            destination.ocMovie = selectedOCMovie;
        } else if (selectedPFMovie) {
            destination.pfMovie = selectedPFMovie;
            destination.movie = selectedMovie;
        } else {
            destination.movie = selectedMovie;
        }
    }
    if ([segue.identifier isEqualToString:@"toTheaterFromShowtimes"]) {
        TheaterViewController *destination = (TheaterViewController *)segue.destinationViewController;
        destination.highlightMovie = selectedMovieTheater;
        destination.theater = selectedTheater;
    }
    if ([segue.identifier isEqualToString:@"toLocationPickerFromShowtimes"]) {
        LocationPickerViewController *destination = (LocationPickerViewController *)segue.destinationViewController;
        destination.delegate = self;
    }
}

- (void)tripleTap {
    [PFUser logOut];
    exit(0);
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
