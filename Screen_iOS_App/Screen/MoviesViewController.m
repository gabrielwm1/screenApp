//
//  FirstViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/6/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "MoviesViewController.h"

#import "MovieTableViewCell.h"
#import "RottenTomatoesHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <STPTransitions.h>
#import "MovieSearchViewController.h"
#import "TMDBHelper.h"
#import "MovieViewController.h"
#import "Constants.h"
#import <MarqueeLabel/MarqueeLabel.h>

@interface MoviesViewController ()

@end

@implementation MoviesViewController

@synthesize tableView;
@synthesize searchController;
@synthesize containerView;
@synthesize titleLabel;

- (void)loadData {
    if (sortType == nowPlaying) {
        if (nowPlayingMovies) {
            movies = nowPlayingMovies;
            self.tableView.totalPages = totalPagesForNowPlaying;
            [self.tableView reloadData];
        } else {
            [[RottenTomatoesHelper sharedInstance] moviesInTheatersPage:1 success:^(NSArray *movs, int totalPages) {
                nowPlayingMovies = movs;
                movies = movs;
                totalPagesForNowPlaying = totalPages;
                self.tableView.totalPages = totalPages;
                [self.tableView reloadData];
            }errorBlock:^(NSError *error) {
                
            }];
        }
    } else if (sortType == boxOffice) {
        self.tableView.totalPages = 1;
        if (boxOfficeMovies) {
            movies = boxOfficeMovies;
            [self.tableView reloadData];
        } else {
            [[RottenTomatoesHelper sharedInstance] boxOfficeMovies:^(NSArray *movs) {
                boxOfficeMovies = movs;
                movies = movs;
                [self.tableView reloadData];
            }errorBlock:^(NSError *error) {
                
            }];
        }
    } else if (sortType == opening) {
        self.tableView.totalPages = 1;
        if (openingMovies) {
            movies = openingMovies;
            [self.tableView reloadData];
        } else {
            [[RottenTomatoesHelper sharedInstance] openingMovies:^(NSArray *movs) {
                openingMovies = movs;
                movies = movs;
                [self.tableView reloadData];
            }errorBlock:^(NSError *error) {
                
            }];
        }
    }
    
}
- (IBAction)changeSort:(id)sender {
    sortType = (int)self.segmentedControl.selectedSegmentIndex;
    [self loadData];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return movies.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieTableViewCell *cell = (MovieTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.titleLabel.text = [(RTMovie*)movies[indexPath.row] title];
    [cell.imageView sd_setImageWithURL:[(RTMovie*)movies[indexPath.row] posters][@"thumbnail"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedMovie = movies[indexPath.row];
    [self performSegueWithIdentifier:@"toMovieFromMovies" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView scrollViewDidScroll:scrollView];
}

- (void)loadPage:(int)page done:(SuccessBlock)done error:(SuccessBlock)error {
    [[RottenTomatoesHelper sharedInstance] moviesInTheatersPage:page success:^(NSArray *results, int totalPages) {
        int oldNumberOfRows = (int)nowPlayingMovies.count;
        
        nowPlayingMovies = [nowPlayingMovies arrayByAddingObjectsFromArray:results];
        movies = nowPlayingMovies;
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (int i = oldNumberOfRows; i < movies.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithArray:indexPaths] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        done();
    }errorBlock:^(NSError *err) {
        error();
    }];
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toMovieFromMovies"]) {
        MovieViewController *destination = (MovieViewController *)segue.destinationViewController;
        destination.rottenTomatoesMovie = selectedMovie;
    }
}

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 43, 0, 8);
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    
    self.tableView.continuousDelegate = self;
    
    self.segmentedControl.tintColor = UIColorFromRGB(blueColor);
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor] } forState:UIControlStateSelected];
    [self.segmentedControl setSelectedSegmentIndex:0];
    sortType = nowPlaying;
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40) duration:8.0f andFadeLength:10.0f];
    titleLabel.text = @"Explore Movies";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;

    [self loadData];
}

//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
//    return NO;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
