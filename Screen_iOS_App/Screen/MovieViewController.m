//
//  MovieViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "MovieViewController.h"
#import "WatchlistsViewController.h"
#import "PersonViewController.h"
#import "MWPopoverView.h"
#import "RadiusSelectorView.h"
#import <AVFoundation/AVFoundation.h>
#import <STPTransitions/STPTransitions.h>
#import "AppDelegate.h"
#import "DemandBarView.h"
#import "OnConnectHelper.h"
#import "ShowtimeTableViewCell.h"
#import "TheaterViewController.h"
#import "AddButton.h"
#import "WatchlistButton.h"
#import "TMDBHelper.h"
#import "RottenTomatoesHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <MarqueeLabel/MarqueeLabel.h>
#import "Tomatometer.h"
#import "ParseHelper.h"
#import "LoadingTableViewCell.h"
#import "LabelTableViewCell.h"
#import "SimilarTableViewCell.h"
#import "AddressBookHelper.h"

@interface MovieViewController () {
    RadiusSelectorView *radiusSelector;
}

@end

@implementation MovieViewController

@synthesize movie = _movie;
@synthesize titleLabel;
@synthesize pfMovie;
@synthesize ocMovie = _ocMovie;
@synthesize rottenTomatoesMovie;
@synthesize watchlistButton;
@synthesize seenButton;
@synthesize changingRadius;

#pragma mark - Setters

- (void)setMovie:(TMDBMovie *)movie {
    _movie = movie;
    //    [self refresh];
}

- (void)setOcMovie:(OCMovie *)ocMovie {
    _ocMovie = ocMovie;
    [[TMDBHelper sharedInstance] movieForOCMovie:ocMovie success:^(TMDBMovie *tmdb) {
        self.movie = tmdb;
        [self refresh];
    }error:^(NSError *error) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self.playImage removeFromSuperview];
        [self.imageView sd_setImageWithURL:[[OnConnectHelper sharedInstance] urlForImageResource:_ocMovie.posterPath size:@"h500" ] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
        [self getShowtimesForOCMove];
        self.summaryTextView.text = _ocMovie.longDescription;
        [self.watchlistButton removeFromSuperview];
        [self.seenButton removeFromSuperview];
    }];
}

- (void)onPlayerWillExitFullScreen:(MPMoviePlayerController*)v {
    NSLog(@"video exit");
}

#pragma mark - Interactions

- (void)tapPoster:(id)sender {
    
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory:AVAudioSessionCategoryPlayback
                    error:&error];
    if (!success) {
        // Handle error here, as appropriate
    }
    
    if ([_movie officialTrailer]) {
        [self playTrailer:[_movie officialTrailer]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Trailer" message:@"There is no trailer for this movie" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)addPress {
    [self animateAdd];
    [[ParseHelper sharedInstance] addMovieToWatchlist:_movie success:^(PFMovie *movie){
        NSLog(@"added movie to watchlist");
        pfMovie = movie;
    }error:^(NSError *error) {

    }];
}

- (void)removeFromWatchlist {
    UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"" message:@"This will remove this movie from your watchlist, but it doesn't quite yet. Also, this icon will be a checkmark" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)tappedMovie:(TMDBMovie *)movie {
    //Similar Movie
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MovieViewController *next = (MovieViewController*)[sb instantiateViewControllerWithIdentifier:@"movieViewController"];
    next.movie = movie;
    [self.navigationController pushViewController:next animated:YES];
}

- (void)tapDirector {
    NSLog(@"tap director");
    if ([_movie directors].count != 0) {
        [self performSegueWithIdentifier:@"toPersonFromMovie" sender:self];
    }
}

- (void)sharePress {
    if (_movie) {
        NSString *shareText = [NSString stringWithFormat:@"Check out %@! http://screenapp.io/share/%@", _movie.title, _movie.tmdbId];
        
        if (_movie && _movie.posterPath && ![_movie.posterPath isEqualToString:@""]) {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:self.movie.posterPath size:@"w500"] options:0 progress:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[shareText, image] applicationActivities:nil];
                share.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
                [self presentViewController:share animated:YES completion:nil];
            }];
        } else {
            UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];
            share.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
            [self presentViewController:share animated:YES completion:nil];
        }
        
    }
}

- (void)tapRadius:(UITapGestureRecognizer *)tap {
    if (self.tableView.contentOffset.y < 60) {
        [self showRadiusPopoverOffset:self.tableView.contentOffset.y - 60];
        [self.tableView setContentOffset:CGPointMake(0, 60) animated:YES];
    } else {
        [self showRadiusPopoverOffset:0];
    }
}

- (void)showRadiusPopoverOffset:(float)offset {
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
        [weakSelf setChangingRadius:YES];
        [[weakSelf tableView] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [weakSelf getShowtimes];
        [popover hideWithDuration:.3f animationBlock:^{
            popover.alpha = 0.0f;
        }];
    };
    radiusSelector.pickLocationHandler = ^{
        [weakSelf performSegueWithIdentifier:@"toLocationPickerFromMovie" sender:weakSelf];
        [popover hideWithDuration:0.0f animationBlock:^{
            popover.alpha = 0.0f;
        }];
    };
    [popover.container addSubview:radiusSelector];

    CGPoint displayPoint = [self.tabBarController.view convertPoint:showtimesHeader.center fromView:showtimesHeader.superview];
    displayPoint.y = displayPoint.y + offset;
    [popover showFromPoint:displayPoint];
}

- (void)pickedLocationWithName:(NSString *)name coordinate:(CLLocation *)location {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"searchLatitude"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"searchLongitude"];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"searchLocationName"];
    
    [self setChangingRadius:YES];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self getShowtimes];
}

- (void)pickedCurrentLocation {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"searchLatitude"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"searchLongitude"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"searchLocationName"];
    
    [self setChangingRadius:YES];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self getShowtimes];
}

- (void)tappedInviteForUser:(PFUser *)user stopActivityIndicator:(BlankBlock)stopAnimating {
    NSLog(@"should invite: %@", user[@"name"]);
    if ([MFMessageComposeViewController canSendText] && _movie) {
        
        
        
        
        NSString *message = [NSString stringWithFormat:@"Let's see %@! http://screenapp.io/share/%@", _movie.title, _movie.tmdbId];
        
        [AddressBookHelper phoneNumberForUser:user success:^(NSString *phoneNumber) {
            if (_movie && _movie.posterPath && ![_movie.posterPath isEqualToString:@""]) {
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager downloadImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:self.movie.posterPath size:@"w500"] options:0 progress:nil
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                        MFMessageComposeViewController *compose = [[MFMessageComposeViewController alloc] init];
                                        compose.messageComposeDelegate = self;
                                        NSLog(@"got image for invite");
                                        [compose addAttachmentData:UIImageJPEGRepresentation(image, .7f) typeIdentifier:@"public.data" filename:@"poster.jpg"];
                                        [compose setBody:message];
                                        if (phoneNumber) {
                                            [compose setRecipients:@[phoneNumber]];
                                        }
                                        [self presentViewController:compose animated:YES completion:^{
                                            stopAnimating();
                                        }];
                                    }];
            } else {
                MFMessageComposeViewController *compose = [[MFMessageComposeViewController alloc] init];
                compose.messageComposeDelegate = self;
                [compose setBody:message];
                if (phoneNumber) {
                    [compose setRecipients:@[phoneNumber]];
                }
                [self presentViewController:compose animated:YES completion:^{
                    stopAnimating();
                }];
            }
            
        }error:^{
            if (_movie && _movie.posterPath && ![_movie.posterPath isEqualToString:@""]) {
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager downloadImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:self.movie.posterPath size:@"w500"] options:0 progress:nil
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                        MFMessageComposeViewController *compose = [[MFMessageComposeViewController alloc] init];
                                        compose.messageComposeDelegate = self;
                                        NSLog(@"got image for invite");
                                        [compose addAttachmentData:UIImageJPEGRepresentation(image, .7f) typeIdentifier:@"public.data" filename:@"poster.jpg"];
                                        [compose setBody:message];
                                        [self presentViewController:compose animated:YES completion:^{
                                            stopAnimating();
                                        }];
                                    }];
            } else {
                MFMessageComposeViewController *compose = [[MFMessageComposeViewController alloc] init];
                compose.messageComposeDelegate = self;
                [compose setBody:message];
                [self presentViewController:compose animated:YES completion:^{
                    stopAnimating();
                }];
            }
        }];
    }
}

#pragma mark - MFMessageDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WatchlistButtons

- (void)markAsSeenTap {
    [self animateToWatchlistSeen:NO];
    [self gotoSeen:YES];
    [[ParseHelper sharedInstance] addMovieToSeen:_movie success:^(PFMovie *movie) {
        pfMovie = movie;
    }error:^(NSError *error) {
        
    }];
    [self showRateView];
}

- (void)markAsUnseenTap {
    [self animateRemoveWatchlistSeen:NO];
    [self gotoSeen:NO];
    [[ParseHelper sharedInstance] removeMovieFromSeen:_movie success:^{
        
    }error:^(NSError *error) {
        
    }];
}

- (void)gotoSeen:(BOOL)seen {
    if (seen) {
        [self gotoWatchlisted:NO];
        [seenButton animateToGreenStateWithTitle:@"I've Seen This"];
        [seenButton removeTarget:self action:@selector(markAsSeenTap) forControlEvents:UIControlEventTouchUpInside];
        [seenButton addTarget:self action:@selector(markAsUnseenTap) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [seenButton animateToGrayStateWithTitle:@"Mark as Seen"];
        [seenButton removeTarget:self action:@selector(markAsUnseenTap) forControlEvents:UIControlEventTouchUpInside];
        [seenButton addTarget:self action:@selector(markAsSeenTap) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addToWatchlistTap {
    [self animateToWatchlistSeen:YES];
    [self gotoWatchlisted:YES];
    [[ParseHelper sharedInstance] addMovieToWatchlist:_movie success:^(PFMovie *movie) {
        pfMovie = movie;
    }error:^(NSError *error) {
        
    }];
}

- (void)removeFromWatchlistTap {
    [self animateRemoveWatchlistSeen:YES];
    [self gotoWatchlisted:NO];
    [[ParseHelper sharedInstance] removeMovieFromWatchlist:_movie success:^{
        
    }error:^(NSError *error) {
        
    }];
}

- (void)gotoWatchlisted:(BOOL)added {
    if (added) {
        [watchlistButton animateToGreenStateWithTitle:@"On Watchlist"];
        [watchlistButton removeTarget:self action:@selector(addToWatchlistTap) forControlEvents:UIControlEventTouchUpInside];
        [watchlistButton addTarget:self action:@selector(removeFromWatchlistTap) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [watchlistButton animateToGrayStateWithTitle:@"+ Watchlist"];
        [watchlistButton removeTarget:self action:@selector(removeFromWatchlistTap) forControlEvents:UIControlEventTouchUpInside];
        [watchlistButton addTarget:self action:@selector(addToWatchlistTap) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Rate View Delegate 

- (void)didRate:(float)rating {
    NSLog(@"did rate: %f", rating);
    [[ParseHelper sharedInstance] rateMovieWithTmdbId:_movie.tmdbId rating:rating success:^{
        
    }errorBlock:^(NSError *error) {
        
    }];
}

#pragma mark - VODAvailability

- (void)tappedVODLink:(NSString *)link {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", link]]];
}

#pragma mark - Animations

- (void)animateToWatchlistSeen:(BOOL)watchlist {
    UIImageView *animateImage = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    [animateImage sd_setImageWithURL:self.imageView.sd_imageURL];
    [self.view insertSubview:animateImage belowSubview:self.playImage];
    
    
    CGPoint target = (watchlist)?[self.view convertPoint:watchlistButton.center fromView:watchlistButton.superview]:[self.view convertPoint:seenButton.center fromView:seenButton.superview];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(animateImage.frame.origin.x + animateImage.frame.size.width/2, animateImage.frame.origin.y + 4*animateImage.frame.size.height/5)];
    [path addCurveToPoint:target controlPoint1:CGPointMake(150, 100) controlPoint2:CGPointMake(150, 100)];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.path = path.CGPath;
    anim.duration = .5f;
    anim.removedOnCompletion = NO;
    [animateImage.layer addAnimation:anim forKey:@"path"];
    animateImage.alpha = .9f;
    
    [UIView animateWithDuration:.35f animations:^{
        animateImage.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.15f animations:^{
            animateImage.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [animateImage removeFromSuperview];
            [self animateToCheckmark];
        }];
    }];
    
    [UIView animateWithDuration:.5f animations:^{
        animateImage.transform = CGAffineTransformMakeScale(.4f, .4f);
    }];
}

- (void)animateRemoveWatchlistSeen:(BOOL)watchlist {
    UIImageView *animateImage = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    animateImage.transform = CGAffineTransformMakeScale(.4f, .4f);
    animateImage.center = CGPointMake(self.view.frame.size.width - 30, 44);
    [animateImage sd_setImageWithURL:self.imageView.sd_imageURL];
    animateImage.alpha = 0.0f;
    [self.view addSubview:animateImage];
    animateImage.center = [self.view convertPoint:self.imageView.center fromView:self.imageView.superview];
    
    CGPoint target = (watchlist)?[self.view convertPoint:watchlistButton.center fromView:watchlistButton.superview]:[self.view convertPoint:seenButton.center fromView:seenButton.superview];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:target];
    [path addCurveToPoint:CGPointMake(self.imageView.frame.origin.x + self.imageView.frame.size.width/2, self.imageView.frame.origin.y + 4*self.imageView.frame.size.height/5) controlPoint1:CGPointMake(150, 100) controlPoint2:CGPointMake(150, 100)];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.path = path.CGPath;
    anim.duration = .5f;
    anim.removedOnCompletion = NO;
    [animateImage.layer addAnimation:anim forKey:@"path"];
    
    [UIView animateWithDuration:.5f animations:^{
        animateImage.alpha = 1.0f;
        animateImage.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        [animateImage removeFromSuperview];
    }];
    
}

- (void)animateAdd {
    UIImageView *animateImage = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    [animateImage sd_setImageWithURL:self.imageView.sd_imageURL];
    [self.view insertSubview:animateImage belowSubview:self.playImage];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(animateImage.frame.origin.x + animateImage.frame.size.width/2, animateImage.frame.origin.y + 4*animateImage.frame.size.height/5)];
    [path addCurveToPoint:CGPointMake(self.view.frame.size.width - 30, 44) controlPoint1:CGPointMake(150, 100) controlPoint2:CGPointMake(150, 100)];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.path = path.CGPath;
    anim.duration = .5f;
    anim.removedOnCompletion = NO;
    [animateImage.layer addAnimation:anim forKey:@"path"];
    animateImage.alpha = .9f;
    
    [UIView animateWithDuration:.35f animations:^{
        animateImage.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.15f animations:^{
            animateImage.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [animateImage removeFromSuperview];
            [self animateToCheckmark];
        }];
    }];
    
    [UIView animateWithDuration:.5f animations:^{
        animateImage.transform = CGAffineTransformMakeScale(.4f, .4f);
    }];
    
}

- (void)removeMovie {
    [[ParseHelper sharedInstance] removeMovieFromWatchlist:_movie success:^{
        [addButton animateToPlus];
        [addButton.tapGesture removeTarget:self action:@selector(removeMovie)];
        [addButton.tapGesture addTarget:self action:@selector(addPress)];
        //        [self.navigationItem setRightBarButtonItem:addButton animated:YES];
        
    }error:^(NSError *Error) {
        
    }];
    
    UIImageView *animateImage = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    animateImage.transform = CGAffineTransformMakeScale(.4f, .4f);
    animateImage.center = CGPointMake(self.view.frame.size.width - 30, 44);
    [animateImage sd_setImageWithURL:self.imageView.sd_imageURL];
    animateImage.alpha = 0.0f;
    [self.view addSubview:animateImage];
    animateImage.center = [self.view convertPoint:self.imageView.center fromView:self.imageView.superview];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.view.frame.size.width - 30, 44)];
    [path addCurveToPoint:CGPointMake(self.imageView.frame.origin.x + self.imageView.frame.size.width/2, self.imageView.frame.origin.y + 4*self.imageView.frame.size.height/5) controlPoint1:CGPointMake(150, 100) controlPoint2:CGPointMake(150, 100)];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.path = path.CGPath;
    anim.duration = .5f;
    anim.removedOnCompletion = NO;
    [animateImage.layer addAnimation:anim forKey:@"path"];
    
    [UIView animateWithDuration:.5f animations:^{
        animateImage.alpha = 1.0f;
        animateImage.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        [animateImage removeFromSuperview];
    }];
}

- (void)animateToCheckmark {
    NSLog(@"animate to checkmark");
    [addButton animateToCheck];
    [addButton.tapGesture removeTarget:self action:@selector(addPress)];
    [addButton.tapGesture addTarget:self action:@selector(removeMovie)];
    //    checkButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(removeMovie)];
    //    [self.navigationItem setRightBarButtonItem:checkButton animated:YES];
}

- (void)animateViewsIn:(NSArray*)views {
    [UIView animateWithDuration:.2f animations:^{
        for (UIView *view in views) {
            view.alpha = 1.0f;
        }
    }];
}

- (void)animateDemandBarIn {
    if (pfMovie) {
        if (demandBar.percentage == 0.0f) {
            demandBar.percentage = 1.0f;
            [UIView animateWithDuration:.3f animations:^{
                demandBar.alpha = .3f;
            }];
        } else {
            demandBar.alpha = 1.0f;
            CGRect frame = demandBar.frame;
            float duration = 1/demandBar.percentage * .5f;
            demandBar.frame = CGRectMake(frame.origin.x, frame.origin.y, 0, frame.size.height);
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                demandBar.frame = frame;
            }completion:nil];
        }
        
    }
}

- (void)animateTomatometerIn {
    [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:.8f initialSpringVelocity:.2f options:0 animations:^{
        tomatometer.percentage = rtMovie.ratings.criticsScore.floatValue/100;
    }completion:nil];
}

#pragma mark - Loading

- (void)refresh {
    [self setPosterImage];
    
    if (_movie) {
        [[TMDBHelper sharedInstance] movieForId:_movie.tmdbId success:^(TMDBMovie *movie) {
            _movie = movie;
            [self doneFetchingMovie];
        }error:^(NSError *error) {
            
        }];
        [self getPFMovieIfNecessary];
        [self getFriends];
        [self getShowtimes];
        [[OnConnectHelper sharedInstance] vodAvailabilityForTMDBMovie:_movie success:^(NSArray *vodAvailability) {
            vodAvailabilities = vodAvailability;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:movieSectionVOD] withRowAnimation:UITableViewRowAnimationAutomatic];
        }error:^(NSError *error) {
            
        }];
    } else if (rottenTomatoesMovie) {
        [[TMDBHelper sharedInstance] movieForImdbId:rottenTomatoesMovie.alternateIds[@"imdb"] success:^(TMDBMovie *movie) {
            _movie = movie;
            [self getFriends];
            [self setPosterImage];
            [self getPFMovieIfNecessary];
            [self doneFetchingMovie];
            [self getShowtimes];
        }error:^(NSError *error) {
            
        }];
    }
    
}

- (void)getPFMovieIfNecessary {
    if (!pfMovie) {
        [[ParseHelper sharedInstance] movieForTmdbMovie:_movie success:^(PFMovie *movie) {
            pfMovie = movie;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }error:^(NSError *error) {
            
        }];
    }
}

- (void)getShowtimes {
    float radius = [[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue];
    
    [[OnConnectHelper sharedInstance] showTimesForMovie:_movie inRadiusOfCurrentLocation:radius success:^(NSArray *results) {
        showtimes = results;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        //        [self.tableView reloadData];
        loadedShowtimes = YES;
        if (showtimes.count > 0) {
            [self getTheaterDetails];
        } else {
            changingRadius = NO;
            showtimes = results;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:movieSectionShowtimes] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }error:^(NSError *error) {
        NSLog(@"error getting showtimes: %@", error.description);
        LoadingTableViewCell *cell = (LoadingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:movieSectionShowtimes]];
        [cell goToErrorRetry];
        cell.retryHandler = ^{
            [self getShowtimes];
        };
    }];
}

- (void)getShowtimesForOCMove {
    float radius = [[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue];

    [[OnConnectHelper sharedInstance] showTimesForOCMovie:_ocMovie inRadiusOfCurrentLocation:radius success:^(NSArray *results) {
        showtimes = results;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        //        [self.tableView reloadData];
        if (showtimes.count > 0) {
            [self getTheaterDetails];
        } else {
            changingRadius = NO;
            showtimes = results;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:movieSectionShowtimes] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }error:^(NSError *error) {
        NSLog(@"error getting oc showtimes");
    }];
}

- (void)getTheaterDetails {
    float radius = [[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue];

    [[OnConnectHelper sharedInstance] theaterDetailsInRadiusOfCurrentLocation:radius success:^(NSArray *res) {
        theaters = res;
        showtimes = [showtimes sortedArrayUsingComparator:^NSComparisonResult(OCOrganizedShowtime *a, OCOrganizedShowtime *b) {
            OCTheater *detailedA = [self detailedTheaterForTheater:a.theater];
            OCTheater *detailedB = [self detailedTheaterForTheater:b.theater];
            
            float aDist = [detailedA.location[@"distance"] floatValue];
            float bDist = [detailedB.location[@"distance"] floatValue];
            if (aDist < bDist) {
                return NSOrderedAscending;
            } else if (bDist < aDist) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        changingRadius = NO;
        //                [self.tableView reloadData];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:movieSectionShowtimes] withRowAnimation:UITableViewRowAnimationFade];
    }error:^(NSError *error) {
        NSLog(@"error getting theaters: %@", error.description);
    }];
}

- (void)getFriends {
    NSLog(@"getting friends...");
    [[ParseHelper sharedInstance] friendsWithMovieSeen:_movie success:^(NSArray *friends) {
        friendsSeen = friends;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:movieSectionFriends] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[ParseHelper sharedInstance] friendsWithMovieOnWatchlist:_movie success:^(NSArray *friendsWa) {
            NSMutableArray *watching = [NSMutableArray array];
            for (PFUser *user in friendsWa) {
                BOOL hasSeen = NO;
                for (PFUser *user2 in friendsSeen) {
                    if ([user2.objectId isEqual:user.objectId]) {
                        hasSeen = YES;
                    }
                }
                if (!hasSeen) {
                    [watching addObject:user];
                }
            }
            friendsWatching = [NSArray arrayWithArray:watching];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:movieSectionFriends] withRowAnimation:UITableViewRowAnimationAutomatic];
        }error:^(NSError *error) {
            NSLog(@"ERROR GETTING FRIENDS ON WATCHLIST");
        }];
    }error:^(NSError *error) {
        NSLog(@"ERROR GETTING FRIENDS SEEN");
    }];
}

- (void)doneFetchingMovie {
    if (rtMovie) {
        _movie.rottenTomatoesScore = rtMovie.ratings.criticsScore;
    }
    [self updateUI];
    if (rottenTomatoesMovie) {
        [self updateRottenTomatoes:rottenTomatoesMovie];
    }
    if (![_movie.imdbId isEqualToString:@""] && _movie.imdbId && !rottenTomatoesMovie) {
        NSString *imdbId = [_movie.imdbId substringFromIndex:2];
        [[RottenTomatoesHelper sharedInstance] movieForIMDBId:imdbId success:^(RTMovie *rtMov) {
            [self updateRottenTomatoes:rtMov];
        }error:^(NSError *error) {
            
        }];
    }
    
    [[ParseHelper sharedInstance] userHasMovieId:_movie.tmdbId success:^(BOOL result) {
        if (result) {
            [self gotoWatchlisted:YES];
        }
    }error:^(NSError *error) {
        
    }];
    
    [[ParseHelper sharedInstance] userHasSeenMovieId:_movie.tmdbId success:^(BOOL result) {
        if (result) {
            [self gotoSeen:YES];
        }
    }error:^(NSError *error) {
        
    }];
}

#pragma mark - Update UI

- (void)setPosterImage {
    if (_movie && _movie.posterPath && ![_movie.posterPath isEqualToString:@""]) {
        [self.imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:_movie.posterPath size:@"w500"] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
    } else {
        self.imageView.image = [UIImage imageNamed:@"blankPoster"];
    }
}

- (void)updateUI {
    self.summaryTextView.text = (_movie.overview)?_movie.overview:@"";
    self.yearLabel.text = [[TMDBHelper sharedInstance] yearForString:_movie.releaseDate];
    if (![_movie officialTrailer]) {
        self.playImage.alpha = 0.0f;
    }
    canLoadSimilar = YES;
    [self.tableView reloadData];

    //    self.similarMoviesView.movies = _movie.similar;
    //    if (_movie.similar.count == 0) {
    //        self.similarMoviesLabel.alpha = 0.0f;
    //    } else {
    //        [self animateViewsIn:@[self.similarMoviesLabel]];
    //    }
    [self updateRuntimeLabel];
    [self updateDirectorLabel];
}

- (void)updateRottenTomatoes:(RTMovie *)rtMov {
    rtMovie = rtMov;
    if (_movie) {
        _movie.rottenTomatoesScore = rtMov.ratings.criticsScore;
    }
    if (pfMovie && rtMov.ratings.criticsScore && ![rtMov.ratings.criticsScore isEqualToString:@""]) {
        pfMovie.rottenTomatoesScore = rtMov.ratings.criticsScore;
        [pfMovie saveEventually];
    }
    [self updateRuntimeLabel];
    canShowTomatoes = YES;
    //    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
    //    [self animateTomatometerIn];
    //    haveAnimatedTomatometer = YES;
}

- (void)updateDirectorLabel {
    NSArray *directors = [_movie directors];
    
    
    if (directors.count == 0) {
        //        self.directorLabel.numberOfLines = 1;
        self.directorLabelHeight.constant = 0.0f;
        self.directorLabel.text = @"No Director";
    } else if (directors.count == 1) {
        //        self.directorLabel.numberOfLines = 1;
        self.directorLabel.text = [directors[0] name];
    } else {
        //        self.directorLabel.numberOfLines = 2;
        //        self.directorLabelHeight.constant = 44.0f;
        self.directorLabel.text = [NSString stringWithFormat:@"%@, %@", [directors[0] name], [directors[1] name]];
    }
}

- (void)updateRuntimeLabel {
    if (rtMovie) {
        self.runtimeLabel.text = [NSString stringWithFormat:@"%@min/%@", (_movie.runtime)?_movie.runtime:@"", (rtMovie.mpaaRating)?rtMovie.mpaaRating:@"N/A"];
    } else {
        self.runtimeLabel.text = [NSString stringWithFormat:@"%@min", (_movie.runtime)?_movie.runtime:@""];
    }
}

#pragma mark - Private

- (void)showRateView {
    RateViewController *rate = [[RateViewController alloc] init];
    rate.delegate = self;
    rate.movieTitle = _movie.title;
    rate.snapshotView = [self.tabBarController.view snapshotViewAfterScreenUpdates:NO];
    
    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void(^executeOnComplete)(BOOL finished)) {
        [containerView addSubview:toView];
        
        [rate animateInCompletion:executeOnComplete origin:self.view.center];
    }];
    
    self.transitioningDelegate = [STPTransitionCenter sharedInstance];
    [self presentViewController:rate usingTransition:transition onCompletion:nil];
}

- (OCTheater *)detailedTheaterForTheater:(OCTheater *)theater {
    OCTheater *match;
    for (OCTheater *t in theaters) {
        if ([t.theaterId isEqualToString:theater.theaterId]) {
            match = t;
        }
    }
    return match;
}

- (void)playTrailer:(TMDBTrailer *)trailer {
    XCDYouTubeVideoPlayerViewController *video = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:[trailer source]];
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setMovieDidDismiss:NO];
    
    [self presentMoviePlayerViewControllerAnimated:video];
}

#pragma mark - Error Handling

- (void)trailerDidFail:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:@"error"];
    
    if ([error code] != 0) {
//        [self performSelector:@selector(playSecond) withObject:nil afterDelay:1.0f];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Trailer Not Found" message:@"This trailer is not available" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        switch ([error code]) {
            case XCDYouTubeErrorRemovedVideo: [alert setMessage:@"This trailer has been removed"]; break;
            case XCDYouTubeErrorRestrictedPlayback: [alert setMessage:@"This trailer is not available for playback"]; break;
            case XCDYouTubeErrorInvalidVideoIdentifier: [alert setMessage:@"This trailer is not available"]; break;
            case XCDYouTubeErrorNetwork: [alert setMessage:@"You need a better network connection."]; break;
            default: [alert setMessage:@"This trailer is not available"]; break;
        }
        
        NSLog(@"trailer failed, count: %i", (int)_movie.youtubeTrailers.count);
        
        for (TMDBTrailer *trailer in _movie.youtubeTrailers) {
            NSLog(@"trailer name: %@", trailer.name);
        }
        
        [self.playImage removeFromSuperview];
        [self.imageView removeGestureRecognizer:tapPoster];
        
        [alert show];
    }
}

- (void)playSecond {
            [self playTrailer:_movie.youtubeTrailers[1]];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == movieSectionRatings) {
        return 1;
    }
    if (section == movieSectionShowtimes) {
        if (changingRadius) {
            return 1;
        } else {
            if (loadedShowtimes && showtimes.count == 0 ) {
                return 0;
            }
            return (showtimes.count==0)?1:showtimes.count;
        }
    }
    if (section == movieSectionFriends) {
        return friendsSeen.count + friendsWatching.count;
    }
    if (section == movieSectionSimilar) {
        if (_movie.class == [TMDBMovie class] && _movie.similar && _movie.similar.count) {
            return 1;
        } else {
            return 0;
        }
    }
    if (section == movieSectionVOD) {
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == movieSectionRatings) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statsCell"];
        if (pfMovie) {
            [(DemandBarView *)[cell viewWithTag:102] setAlpha:1.0f];
            [(DemandBarView *)[cell viewWithTag:102] setPercentage:(float)pfMovie.userCount/(float)[[ParseHelper sharedInstance] maxDemandFromUsersMovies]];
            [(UILabel *)[cell viewWithTag:104] setText:[NSString stringWithFormat:@"Demand: %i", pfMovie.userCount]];
        } else {
            [(DemandBarView *)[cell viewWithTag:102] setPercentage:1.0];
            [(DemandBarView *)[cell viewWithTag:102] setAlpha:.3f];
            [(UILabel *)[cell viewWithTag:104] setText:@"Demand: 0"];
        }
        if ([rtMovie.ratings.criticsScore isEqualToString:@""] || [rtMovie.ratings.criticsScore isEqualToString:@"-1"] || !rtMovie.ratings.criticsScore) {
            [(Tomatometer *)[cell.contentView viewWithTag:101] setPercentage:0.0];
            [(Tomatometer *)[cell.contentView viewWithTag:101] setAlpha:0.3f];
            [(UILabel *)[cell.contentView viewWithTag:103] setText:@"Tomatometer: N/A"];
        } else {
            [(Tomatometer *)[cell.contentView viewWithTag:101] setPercentage:rtMovie.ratings.criticsScore.floatValue/100];
            [(Tomatometer *)[cell.contentView viewWithTag:101] setAlpha:1.0f];
            [(UILabel *)[cell.contentView viewWithTag:103] setText:[NSString stringWithFormat:@"Tomatometer: %@%%", rtMovie.ratings.criticsScore]];
        }
        demandBar = (DemandBarView *)[cell viewWithTag:102];
        if (pfMovie) {
            demandBar.alpha = (viewHasAppeared)?1.0f:0.0f;
        }
        tomatometer = (Tomatometer *)[cell viewWithTag:101];
        return cell;
    }
    if (indexPath.section == movieSectionShowtimes) {
        if (changingRadius) {
            LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
            [cell start];
            return cell;
        } else if (showtimes.count == 0) {
            LabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"labelCell"];
            cell.label.text = [NSString stringWithFormat:@"No showtimes within %.01f mi", [[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue]];
            return cell;
        } else {
//            ShowtimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showtimeCell"];
            ShowtimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"manualShowtimesCell"];
            
            cell.titleLabel.text = [[showtimes[indexPath.row] theater] name];
            cell.timesLabel.textColor = UIColorFromRGB(blueColor);
            
            OCTheater *detailedTheater = [self detailedTheaterForTheater:[(OCOrganizedShowtime *)showtimes[indexPath.row] theater]];
            if (detailedTheater) {
                cell.distanceLabel.text = [NSString stringWithFormat:@"%.01f mi", [detailedTheater.location[@"distance"] floatValue]];
            } else {
                cell.distanceLabel.text = @"";
            }
            
            if (indexPath.row < showtimes.count - 1) {
                cell.separator.alpha = .5f;
            } else {
                cell.separator.alpha = 0.0f;
            }
            
            if ([showtimes[indexPath.row] timesDaysAfterToday:0].count == 0) {
                cell.timesLabel.text = [[OnConnectHelper sharedInstance] closestDatePlayingForShowtime:showtimes[indexPath.row]];
            } else {
                cell.timesLabel.attributedText = [[OnConnectHelper sharedInstance] attributedStringForTimes:[showtimes[indexPath.row] timesDaysAfterToday:0] beforeColor:[UIColor whiteColor] afterColor:UIColorFromRGB(blueColor)];
            }
            
            [cell setNeedsUpdateConstraints];
            [cell updateConstraintsIfNeeded];
            
            return cell;
        }
        
    }
    if (indexPath.section == movieSectionFriends) {
//        FriendMovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
        FriendMovieTableViewCell *cell;
        
        PFUser *friend;
        if (indexPath.row < friendsSeen.count) {
            friend = friendsSeen[indexPath.row];
        }
        
        if (friend && [[friend objectForKey:@"ratings"] objectForKey:_movie.tmdbId]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"manualFriendRatingCell"];
        } else if (indexPath.row < friendsSeen.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"manualFriendCell"];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"manualFriendInviteCell"];
            cell.delegate = self;
        }
        
        if (indexPath.row < friendsSeen.count) {
            //friendsSeen
//            PFUser *friend = friendsSeen[indexPath.row];
            if ([[friend objectForKey:@"ratings"] objectForKey:_movie.tmdbId]) {
//                cell = [tableView dequeueReusableCellWithIdentifier:@"friendRatingCell"];
                cell.starRating.rating = [[[friend objectForKey:@"ratings"] objectForKey:_movie.tmdbId] floatValue];
            } else {
                cell.statusLabel.text = @"Seen";
                cell.statusLabel.textColor = UIColorFromRGB(greenColor);
            }
            cell.user = friend;
        } else {
            //friends watching
            cell.user = friendsWatching[indexPath.row - friendsSeen.count];
//            cell.statusLabel.text = @"On Watchlist";
//            cell.statusLabel.textColor = UIColorFromRGB(blueColor);
        }
        
        if (indexPath.row < [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
            cell.separator.alpha = .5f;
        } else {
            cell.separator.alpha = 0.0f; 
        }
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        return cell;
    }
    if (indexPath.section == movieSectionSimilar) {
        
        SimilarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"manualSimlarCell"];
        if (canLoadSimilar) {
            cell.similarMoviesView.delegate = self;
            cell.similarMoviesView.movies = _movie.similar;
            cell.similarMoviesView.collectionView.contentInset = UIEdgeInsetsMake(0, 13, 0, 13);
        }
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        return cell;
        
    }
    if (indexPath.section == movieSectionVOD) {
        NSLog(@"VOD CELL");
        VODTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"vodCell"];
        cell.delegate = self;
        cell.screenWidth = self.view.frame.size.width;
        cell.vodAvailabilities = vodAvailabilities;
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header;
    
    if (section == movieSectionShowtimes) {
        header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"showtimesHeader"];
    } else {
        header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    }
    
    if (![header viewWithTag:101]) {
        header.contentView.backgroundColor = [UIColor clearColor];

        header.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(13, 0, self.tableView.frame.size.width - 26, 30)];
        header.backgroundView.backgroundColor = UIColorFromRGB(0x1e2227);
        header.backgroundView.alpha = 0.0f;
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(13, 0, self.tableView.frame.size.width - 26, 30)];
        background.backgroundColor = UIColorFromRGB(0x1e2227);
        background.alpha = .7f;
        [header.contentView addSubview:background];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, self.tableView.frame.size.width - 33, 30)];
        label.textColor = [UIColor whiteColor];
        label.tag = 101;
        label.backgroundColor = [UIColor clearColor];
        [header.contentView addSubview:label];
        
        if (section == 1) {
            UILabel *radiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 205, 0, 205-23-12, 30)];
            radiusLabel.textAlignment = NSTextAlignmentRight;
//            radiusLabel.userInteractionEnabled = YES;
            radiusLabel.tag = 102;
            radiusLabel.font = [UIFont systemFontOfSize:12.0f];
            radiusLabel.backgroundColor = [UIColor clearColor];
            radiusLabel.textColor = UIColorFromRGB(blueColor);
            [header.contentView addSubview:radiusLabel];
            
            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 13 - 9.5 - 9.5, 9.5, 11, 11)];
            arrow.image = [UIImage imageNamed:@"detailDisclosure"];
            [header.contentView addSubview:arrow];
            
            UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
            [header.contentView addSubview:tapView];
            
            UITapGestureRecognizer *tapRadius = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRadius:)];
            [tapView addGestureRecognizer:tapRadius];
        }
    }
    
    NSString *title;
    switch (section) {
        case movieSectionShowtimes:
            title = @"Showtimes"; break;
        case movieSectionFriends:
            title = @"Friends"; break;
        case movieSectionSimilar:
            title = @"Similar"; break;
        default: title = @""; break;
    }
    [(UILabel *)[header viewWithTag:101] setText:title];
    
    NSString *location = @"Current Location";
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"searchLocationName"]) {
        location = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchLocationName"];
    }
    if (section == movieSectionShowtimes) {
        [(UILabel *)[header viewWithTag:102] setText:[NSString stringWithFormat:@"%.01f mi near %@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue], location]];
        showtimesHeader = header;
    }
    
    return header;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == movieSectionRatings || indexPath.section == movieSectionSimilar || indexPath.section == movieSectionVOD) {
        return NO;
    }
    if (showtimes.count == 0 && indexPath.section == movieSectionShowtimes) {
        return NO;
    }
    return YES;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 3) {
//        return 141;
//    }
//    return 55;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == movieSectionRatings || section == movieSectionVOD) {
        return 0;
    }
    if ([self tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    }
    if (section == movieSectionShowtimes) {
        if (loadedShowtimes && !changingRadius && showtimes.count == 0) {
            return 0;
        }
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == movieSectionVOD && vodAvailabilities.count == 0) {
        return 0.0f;
    }
    
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == movieSectionShowtimes) {
        if (!changingRadius && indexPath.row < showtimes.count) {
            selectedShowtime = showtimes[indexPath.row];
            [self performSegueWithIdentifier:@"toTheaterFromMovie" sender:self];
        }
    }
    if (indexPath.section == movieSectionFriends) {
        if (indexPath.row < friendsSeen.count) {
            selectedUser = friendsSeen[indexPath.row];
        } else {
            selectedUser = friendsWatching[indexPath.row - friendsSeen.count];
        }
        [self performSegueWithIdentifier:@"toWatchlistsFromMovie" sender:self];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    tapPoster = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPoster:)];
    [self.imageView addGestureRecognizer:tapPoster];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePress)];
    
    self.imageView.userInteractionEnabled = YES;
    
    changingRadius = YES;
    
    self.directorLabel.text = @"";
    self.yearLabel.text = @"";
    self.runtimeLabel.text = @"";
    self.summaryTextView.text = @"";
    self.imageView.image = nil;
    
    self.summaryTextView.editable = NO;
    self.summaryTextView.selectable = NO;
    
//    self.tomatometerLabel.alpha = 0.0f;
//    self.tomatometer.alpha = 0.0f;

//    self.similarMoviesLabel.alpha = 0.0f;
    
//    self.similarMoviesView.delegate = self;
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40)];
    titleLabel.rate = 20.0f;
    titleLabel.fadeLength = 10.0f;
    titleLabel.marqueeType = MLContinuous;
    titleLabel.text = (_movie)?[_movie displayTitle]:(_ocMovie)?_ocMovie.title:rtMovie.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    addButton = [[AddButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    addButton.plusColor = [UIColor whiteColor];
    addButton.checkColor = UIColorFromRGB(0x60b050);
    addButton.lineWidth = 2.0f;
    addButton.checkWidth = 3.0f;
    rightButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    [addButton.tapGesture addTarget:self action:@selector(addPress)];

//    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -10);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 55.0f;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"showtimesHeader"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"footer"];
    [self.tableView registerClass:[LoadingTableViewCell class] forCellReuseIdentifier:@"loadingCell"];
    [self.tableView registerClass:[LabelTableViewCell class] forCellReuseIdentifier:@"labelCell"];
    [self.tableView registerClass:[ShowtimeTableViewCell class] forCellReuseIdentifier:@"manualShowtimesCell"];
    [self.tableView registerClass:[SimilarTableViewCell class] forCellReuseIdentifier:@"manualSimlarCell"];
    [self.tableView registerClass:[FriendMovieTableViewCell class] forCellReuseIdentifier:@"manualFriendRatingCell"];
    [self.tableView registerClass:[FriendMovieTableViewCell class] forCellReuseIdentifier:@"manualFriendCell"];
    [self.tableView registerClass:[FriendMovieTableViewCell class] forCellReuseIdentifier:@"manualFriendInviteCell"];
    [self.tableView registerClass:[VODTableViewCell class] forCellReuseIdentifier:@"vodCell"];
    
    [self gotoSeen:NO];
    [self gotoWatchlisted:NO];
    
    UITapGestureRecognizer *tapDirector = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDirector)];
    self.directorLabel.userInteractionEnabled = YES;
    [self.directorLabel addGestureRecognizer:tapDirector];
    
    if (!_ocMovie) {
        [self refresh];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trailerDidFail:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
//    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (!viewHasAppeared) {
        [self animateDemandBarIn];
    }
    viewHasAppeared = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = _tableView.indexPathForSelectedRow;
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
    if ([segue.identifier isEqualToString:@"toWatchlistsFromMovie"]) {
        WatchlistsViewController *watchlist = segue.destinationViewController;
        watchlist.friendViewing = selectedUser;
    }
    if ([segue.identifier isEqualToString:@"toPersonFromMovie"]) {
        PersonViewController *destination = (PersonViewController *)segue.destinationViewController;
        NSArray *directors = [_movie directors];
        
        
        if (directors.count == 0) {

        } else if (directors.count == 1) {
            destination.director = directors[0];
        } else {
            destination.director = directors[0];
        }
    }
    if ([segue.identifier isEqualToString:@"toTheaterFromMovie"]) {
        TheaterViewController *theaterVC = (TheaterViewController *)segue.destinationViewController;
        theaterVC.theater = [self detailedTheaterForTheater:selectedShowtime.theater];
    }
    if ([segue.identifier isEqualToString:@"toLocationPickerFromMovie"]) {
        LocationPickerViewController *destination = (LocationPickerViewController *)segue.destinationViewController;
        destination.delegate = self;
    }
}


//- (BOOL)shouldAutorotate {
//    return NO;
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationPortrait;
//}

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
