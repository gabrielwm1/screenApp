//
//  PersonViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/13/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "PersonViewController.h"
#import "ParseHelper.h"

@interface PersonViewController ()

@end

@implementation PersonViewController

@synthesize person;
@synthesize titleLabel;
@synthesize tableView;
@synthesize imageView;
@synthesize textView;
@synthesize director;

- (void)loadData {
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

- (void)refresh {
    [[TMDBHelper sharedInstance] personForId:(director)?director.crewId:person.personId success:^(TMDBPerson *pers) {
        fullPerson = pers;
        
        ComparisonBlock comparator = ^NSComparisonResult(TMDBMovie *a, TMDBMovie *b) {
            return [[[TMDBHelper sharedInstance] dateFromString:b.releaseDate] compare:[[TMDBHelper sharedInstance] dateFromString:a.releaseDate]];
        };
        
        sortedAsCast = pers.asCast;
        sortedAsCast = [sortedAsCast arrayByAddingObjectsFromArray:pers.asCrew];
        sortedAsCast = [self removeDuplicates:[sortedAsCast sortedArrayUsingComparator:comparator]];
//        sortedAsCrew = [self removeDuplicates:[pers.asCrew sortedArrayUsingComparator:comparator]];
        
        NSLog(@"person id: %@", pers.personId);
        
        [self refreshFullUI];
    }error:^(NSError *error) {
        
    }];
}

- (void)tappedAddButtonAtIndexPath:(NSIndexPath *)indexPath {
    MovieSearchTableViewCell *cell = (MovieSearchTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.statusButton.status == movieAdd) {
        TMDBMovie *movie = (indexPath.section == 0)?sortedAsCast[indexPath.row]:sortedAsCrew[indexPath.row];
        [[ParseHelper sharedInstance] addMovieToWatchlist:movie success:^(id object) {
            [cell.statusButton animateToStatus:movieOnWatchlist];
        }error:^(NSError *error) {
            [cell.statusButton goToFailForDuration:1.0];
        }];
    }
    
    cell.statusButton.status = statusLoading;
}

- (NSArray *)removeDuplicates:(NSArray *)arr {
    NSMutableArray *unique = [NSMutableArray array];
    NSMutableArray *ids = [NSMutableArray array];
    
    for (TMDBMovie *movie in arr) {
        if (![self containsId:movie.tmdbId array:ids]) {
            [unique addObject:movie];
            [ids addObject:movie.tmdbId];
        }
    }
    return [NSArray arrayWithArray:unique];
}

- (BOOL)containsId:(NSString *)idd array:(NSArray *)array {
    BOOL contains = NO;
    
    for (NSString *str in array) {
        if ([str isEqualToString:idd]) {
            contains = YES;
            return YES;
        }
    }
    
    return contains;
}

- (void)refreshUI {
    titleLabel.text = (person)?person.name:director.name;
    
    NSString *profilePath = (person)?person.profilePath:director.profilePath;
    
    if (profilePath && ![profilePath isEqualToString:@""]) {
        [imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:profilePath size:@"w500"] placeholderImage:[UIImage imageNamed:@"blankUser"]];
    } else {
        imageView.image = [UIImage imageNamed:@"blankUser"];
    }
    
}

- (void)refreshFullUI {
    [tableView reloadData];
    NSLog(@"birthday: %@", fullPerson.birthday);
    NSString *birthday;
    if (fullPerson.birthday) {
        birthday = [[TMDBHelper sharedInstance] formattedDateFromString:fullPerson.birthday];
        if (!birthday) {
            birthday = fullPerson.birthday;
        }
    } else {
        birthday = @"N/A";
    }
    textView.text = [NSString stringWithFormat:@"Birthday: %@\n\nBirthplace: %@\n\n%@",
                     birthday,
                     (fullPerson.placeOfBirth)?fullPerson.placeOfBirth:@"N/A",
                     (fullPerson.biography)?fullPerson.biography:@""];
    textView.textColor = [UIColor whiteColor];
}

#pragma mark - UITableView

- (void)reloadTable {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return sortedAsCast.count;
    } else {
        return sortedAsCrew.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    TMDBMovie *movie;
    if (indexPath.section == 0) {
        movie = sortedAsCast[indexPath.row];
    } else {
        movie = sortedAsCrew[indexPath.row];
    }
    
    if (movie.posterPath && ![movie.posterPath isEqualToString:@""]) {
        [cell.imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"]];
        [cell.imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"blankPoster"];
    }
    
    cell.titleLabel.text = [movie displayTitle];
    
    [self setCorrectStatusOnCell:cell movie:movie];
    
    return cell;
}

- (void)setCorrectStatusOnCell:(MovieSearchTableViewCell *)cell movie:(TMDBMovie *)movie {
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

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        selectedMovie = sortedAsCast[indexPath.row];
    } else {
        selectedMovie = sortedAsCrew[indexPath.row];
    }

    [self performSegueWithIdentifier:@"toMovieFromPerson" sender:self];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView.text = @"";
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40) duration:8.0f andFadeLength:10.0f];
    titleLabel.text = person.name;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    [self refresh];
    [self refreshUI];
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:parseDidAddMovieToWatchlistNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:parseDidAddMovieToSeenNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toMovieFromPerson"]) {
        NSLog(@"To movie from person");
        NSLog(@"selected movie: %@, id: %@", selectedMovie.title, selectedMovie.tmdbId);
        MovieViewController *destination = (MovieViewController *)segue.destinationViewController;
        destination.movie = selectedMovie;
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
