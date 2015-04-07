//
//  TheaterViewController.m
//  Screen
//
//  Created by Mason Wolters on 12/4/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TheaterViewController.h"
#import "MovieViewController.h"
#import <HMSegmentedControl/HMSegmentedControl.h>

@interface TheaterViewController ()

@end

@implementation TheaterViewController

@synthesize theater;
@synthesize starRating;
@synthesize segmentedControl;
@synthesize highlightMovie;
@synthesize phoneButton;

#pragma mark - Interaction

- (IBAction)sortingChange:(id)sender {
    [self filterShowtimes];
    [self.tableView reloadData];
}

- (IBAction)tapDirections:(id)sender {
    CLLocationCoordinate2D coordinate =
    CLLocationCoordinate2DMake([theater getLatitude], [theater getLongitude]);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:@{}];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:theater.name];
    
    // Set the directions mode to "Walking"
    // Can use MKLaunchOptionsDirectionsModeDriving instead
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    // Get the "Current User Location" MKMapItem
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    // Pass the current location and destination map items to the Maps app
    // Set the direction mode in the launchOptions dictionary
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                   launchOptions:launchOptions];
}

- (IBAction)tapCallButton:(id)sender {
    NSString *phNo = theater.phoneNumber;
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
}

#pragma mark - Private

- (void)loadData {
    [[GooglePlacesHelper sharedInstance] findTheaterWithName:theater.name latitude:[NSString stringWithFormat:@"%f", [theater getLatitude]] longitude:[NSString stringWithFormat:@"%f", [theater getLongitude]] success:^(GPPlace *place) {
        theaterPlace = place;
        [self refreshUI];
    }error:^(NSError *error) {
        
    }];
    
    [[OnConnectHelper sharedInstance] showTimesForTheater:theater success:^(NSArray *results) {
        allShowtimes = results;
        [self filterShowtimes];
        [self.tableView setNeedsUpdateConstraints];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        if (viewHasAppeared) {
            [self highlightMovieIfNecessary];
        }
//        [self.tableView reloadData];
    }error:^(NSError *error) {
        
    }];
}

- (void)refreshUI {
    if (theaterPlace.photos.count > 0) {
//        [self.imageView sd_setImageWithURL:[[GooglePlacesHelper sharedInstance] urlForPhotoReference:[(GPPhoto*)theaterPlace.photos[0] photoReference] maxWidth:500] placeholderImage:[UIImage imageNamed:@"blankTheater"]];
    }
    
    if (theaterPlace.rating) {
        starRating.rating = theaterPlace.rating.floatValue;
        starRating.alpha = 1.0f;
    } else {
        starRating.alpha = 0.0f;
    }
}

- (void)filterShowtimes {
    NSMutableArray *filtered = [NSMutableArray array];
    for (OCOrganizedShowtime *showtime in allShowtimes) {
        if (showtime.movie.title && ![showtime.movie.title isEqualToString:@""]) {
            if ([[showtime timesDaysAfterToday:(int)self.segmentedControl.selectedSegmentIndex] count] != 0) {
                [filtered addObject:showtime];
            }
        }
    }
    showtimes = [NSArray arrayWithArray:filtered];
}

- (void)highlightMovieIfNecessary {
    if (highlightMovie) {
        int index = [self indexOfMovie:highlightMovie];
        if (index != -1) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        
//        if (index == showtimes.count - 1 && showtimes.count > 4) {
//            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height + 80) animated:YES];
//        } else {
//        }
        

    }
}

- (int)indexOfMovie:(OCMovie *)movie {
    int index = -1;
    
    int i = 0;
    for (OCOrganizedShowtime *showtime in showtimes) {
        if ([showtime.movie.tmsId isEqualToString:movie.tmsId]) {
            index = i;
        }
        i++;
    }
    
    return index;
}

- (NSDateFormatter *)dateFormatter {
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ccc M/d"];
    }
    
    return dateFormatter;
}

- (NSString *)stringForDayAfterTomorrow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSIntegerMax fromDate:[NSDate date]];
    components.day += 2;
    return [[self dateFormatter] stringFromDate:[calendar dateFromComponents:components]];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return showtimes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TheaterShowtimeTableViewCell *cell = (TheaterShowtimeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"manualCell"];
    
    OCOrganizedShowtime *showtime = showtimes[indexPath.row];
    cell.titleLabel.text = showtime.movie.title;
    
    NSArray *times = [showtime timesDaysAfterToday:(int)self.segmentedControl.selectedSegmentIndex];
    if (times.count == 0) {
        cell.timesLabel.text = [[OnConnectHelper sharedInstance] closestDatePlayingForShowtime:showtime];
    } else {
        cell.timesLabel.attributedText = [[OnConnectHelper sharedInstance] attributedStringForTimes:times beforeColor:[UIColor whiteColor] afterColor:UIColorFromRGB(blueColor)];
    }
//    cell.timesLabel.alpha = (viewHasAppeared)?1.0f:0.0f;
    [cell.imageView sd_setImageWithURL:[[OnConnectHelper sharedInstance] urlForImageResource:showtime.movie.posterPath size:@"h=120"] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
    
//    [cell.contentView layoutIfNeeded];
//    [cell.contentView sizeToFit];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedOcMovie = [showtimes[indexPath.row] movie];
    [self performSegueWithIdentifier:@"toMovieFromTheater" sender:self];
    
//    [[TMDBHelper sharedInstance] movieForOCMovie:[showtimes[indexPath.row] movie] success:^(TMDBMovie *movie) {
//        if (movie) {
//            selectedMovie = movie;
//            [self performSegueWithIdentifier:@"toMovieFromTheater" sender:self];
//        }
//    }error:^(NSError *error) {
//        
//    }];
}

#pragma mark - UIViewController

- (void)viewDidLayoutSubviews {
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    CGColorRef black = [UIColor colorWithWhite:1.0 alpha:0.02].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    CGColorRef halfwayColor = [UIColor colorWithWhite:1.0 alpha:.7f].CGColor;
    
    maskLayer.colors = [NSArray arrayWithObjects:(__bridge id)outerColor, (__bridge id)halfwayColor,
                        (__bridge id)innerColor, (__bridge id)innerColor, (__bridge id)black, nil];
    maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                           @0.23f,
                           @0.28f,
                           [NSNumber numberWithFloat:0.85],
                           [NSNumber numberWithFloat:1.0], nil];
    
    maskLayer.bounds = CGRectMake(0, 0,
                                  self.map.frame.size.width,
                                  self.map.frame.size.height);
    maskLayer.anchorPoint = CGPointZero;
    

    self.map.layer.mask = maskLayer;
    
    CAGradientLayer *containerMask = [CAGradientLayer layer];
    
    CGColorRef fullOuterColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
    
    containerMask.colors = [NSArray arrayWithObjects:(__bridge id)innerColor,
                        (__bridge id)innerColor, (__bridge id)innerColor, (__bridge id)fullOuterColor, nil];
    containerMask.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.05],
                           [NSNumber numberWithFloat:0.8],
                           [NSNumber numberWithFloat:1.0], nil];
    
    containerMask.bounds = CGRectMake(0, 0,
                                  self.containerView.frame.size.width,
                                  self.containerView.frame.size.height);
    containerMask.anchorPoint = CGPointZero;
    
    self.containerView.layer.mask = containerMask;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    segmentedControl.tintColor = UIColorFromRGB(blueColor);
//    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor] } forState:UIControlStateSelected];
//    [self.segmentedControl setSelectedSegmentIndex:0];
//    [self.segmentedControl setTitle:[self stringForDayAfterTomorrow] forSegmentAtIndex:2];

    segmentedControl.font = [UIFont systemFontOfSize:14.0f];
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    segmentedControl.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.8f];
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectedTextColor = [UIColor whiteColor];
    segmentedControl.selectionIndicatorBoxOpacity = .3f;
    segmentedControl.selectionIndicatorColor = UIColorFromRGB(blueColor);
    [self addSegments];
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40)];
    titleLabel.rate = 20.0f;
    titleLabel.fadeLength = 10.0f;
    titleLabel.marqueeType = MLContinuous;
    titleLabel.text = (theater)?theater.name:@"";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
//    self.imageView.image = [UIImage imageNamed:@"blankTheater"];
    
    NSLog(@"star rating exists: %@", (starRating)?@"YES":@"NO");
    starRating.backgroundColor = [UIColor clearColor];
    starRating.starImage = [[UIImage imageNamed:@"star-template.png"] imageWithColor:UIColorFromRGB(0xffa200)];
    starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithColor:UIColorFromRGB(0xffa200)];
    starRating.maxRating = 5.0;
//    starRating.delegate = self;
    starRating.horizontalMargin = 12;
//    starRating.editable=YES;
    starRating.rating= 0.0;
    starRating.displayMode = EDStarRatingDisplayAccurate;
    starRating.alpha = 0.0f;

    self.distanceLabel.text = [NSString stringWithFormat:@"%.01f miles away", [theater getDistance]];
//    self.addressLabel.text = [NSString stringWithFormat:@"%@,\n%@, %@, %@", theater.address[@"street"], theater.address[@"city"], theater.address[@"state"], theater.address[@"postalCode"]];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 55.0f;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 43, 0, 8);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    [self.tableView registerClass:[TheaterShowtimeTableViewCell class] forCellReuseIdentifier:@"manualCell"];
    
//    UITapGestureRecognizer *tapAddress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddress)];
//    self.addressLabel.userInteractionEnabled = YES;
//    [self.addressLabel addGestureRecognizer:tapAddress];
    
    CLLocationCoordinate2D theaterLocation =  CLLocationCoordinate2DMake([theater getLatitude], [theater getLongitude]);
    

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(theaterLocation, [theater getDistance] * 2000, [theater getDistance] * 2000);
    self.map.showsUserLocation = YES;
    [self.map setRegion:region animated:NO];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = theaterLocation;
    [self.map addAnnotation:point];
    
    self.map.mapType = MKMapTypeHybrid;
    
    if (!self.theater.phoneNumber || [self.theater.phoneNumber isEqualToString:@""]) {
        phoneButton.alpha = 0.0f;
    }
        
//    viewHasAppeared = YES;
//    [self performSelector:@selector(loadData) withObject:nil afterDelay:.1f];
    [self loadData];
}

- (void)addSegments {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSIntegerMax fromDate:[NSDate date]];
    
    NSMutableArray *titles = [NSMutableArray arrayWithArray:@[@"Today"]];
    for (int i = 1; i < numberOfDaysShowtimes; i++) {
        todayComponents.day++;
        [titles addObject:[[self dateFormatter] stringFromDate:[calendar dateFromComponents:todayComponents]]];
    }
    segmentedControl.sectionTitles = [NSArray arrayWithArray:titles];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toMovieFromTheater"]) {
        MovieViewController *destination = (MovieViewController *)segue.destinationViewController;
//        destination.movie = selectedMovie;
        destination.ocMovie = selectedOcMovie;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    self.map = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    if (!viewHasAppeared) {
        viewHasAppeared = YES;
        [self highlightMovieIfNecessary];

//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    

//    [self.tableView reloadData];
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
