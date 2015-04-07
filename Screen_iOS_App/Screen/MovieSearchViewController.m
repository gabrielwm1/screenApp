//
//  MovieSearchViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/7/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "MovieSearchViewController.h"
#import <PureLayout/PureLayout.h>

@interface MovieSearchViewController ()

@end

@implementation MovieSearchViewController

@synthesize backgroundImageView;

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

- (void)animateInOnCompletion:(CompletionBlock)complete {
    backgroundImageView.alpha = 0.0f;
    self.tableView.alpha = 0.0f;
    searchBarView.transform = CGAffineTransformMakeTranslation(0, -64);
    [UIView animateWithDuration:.20f animations:^{
        backgroundImageView.alpha = 1.0f;
        self.tableView.alpha = 1.0f;
    }completion:complete];
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:.3f options:0 animations:^{
        searchBarView.transform = CGAffineTransformIdentity;
    }completion:nil];
}

- (void)animateOutWithDuration:(CGFloat)duration complete:(CompletionBlock)complete {
    [UIView animateWithDuration:.2f animations:^{
        backgroundImageView.alpha = 0.0f;
        self.tableView.alpha = 0.0f;
        searchBarView.alpha = 0.0f;
        searchBarView.frame = CGRectMake(searchBarView.frame.origin.x, searchBarView.frame.origin.y - 64, searchBarView.frame.size.width, searchBarView.frame.size.height);
    } completion:complete];
}

#pragma mark - TextField Delegate

- (void)didChangeSearchText:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        movies = [NSArray array];
        people = nil;
        canLoadMoreMovies = NO;
        [self hideReccommendAMovie];
        self.tableView.totalPages = 0;
        [self.tableView reloadData];
//        [self hideRequest:YES];
    } else {
        [self hideRequest:NO];
        [[TMDBHelper sharedInstance] moviesForSearch:searchText page:1 success:^(NSArray *results, int totalPages) {
                movies = results;
//                self.tableView.totalPages = totalPages;
            self.tableView.totalPages = 1;
            currentLoadedPage = 1;
            if (totalPages > 1) {
                canLoadMoreMovies = YES;
            } else {
                canLoadMoreMovies = NO;
            }
        
            [self searchPeople:searchText];
//                if (movies.count < 20) {
//                    [self searchPeople:searchText];
//                } else {
//                    people = nil;
//                }
        
            [self.tableView reloadData];
        }error:^(NSError *error) {
            
        }];
        //        [[OnConnectHelper sharedInstance] moviesForSearch:searchText page:1 success:^(NSArray *results, int totalPages) {
        //            movies = results;
        //            [self.tableView reloadData];
        //        }error:^(NSError *error) {
        //
        //        }];
    }
}

- (void)searchMovies:(NSString *)search {

}

- (void)searchPeople:(NSString *)search {
    [[TMDBHelper sharedInstance] peopleForSearch:search success:^(NSArray *results) {
        people = [results sortedArrayUsingComparator:^NSComparisonResult(TMDBPerson *a, TMDBPerson *b) {
            return [b.popularity floatValue] - [a.popularity floatValue];
        }];
        [self.tableView reloadData];
    }error:^(NSError *error) {
        
    }];
}

- (void)showReccommendAMovie {
    
}

- (void)hideReccommendAMovie {
    
}

#pragma mark - Movie Cell Delegate

- (void)tappedAddButtonAtIndexPath:(NSIndexPath *)indexPath {
    MovieSearchTableViewCell *cell = (MovieSearchTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.statusButton.status == movieAdd) {
        [[ParseHelper sharedInstance] addMovieToWatchlist:movies[indexPath.row] success:^(id object) {
            cell.statusButton.status = movieOnWatchlist;
        }error:^(NSError *error) {
            [cell.statusButton goToFailForDuration:1.0];
        }];
    }
    
    cell.statusButton.status = statusLoading;
    
}

#pragma mark - Private

- (void)cancelPress {
    [searchBarView.textField resignFirstResponder];

    self.navigationController.transitioningDelegate = [STPTransitionCenter sharedInstance];
    self.navigationController.delegate = [STPTransitionCenter sharedInstance];

    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void (^executeOnComplete)(BOOL finished)) {
        [containerView insertSubview:toView belowSubview:fromView];
        [self animateOutWithDuration:.5f complete:^(BOOL finished) {
            executeOnComplete(YES);
        }];
    }];
    
//    [self.navigationController dismissViewControllerUsingTransition:transition onCompletion:nil];
//    [self dismissViewControllerUsingTransition:transition onCompletion:nil];
    [self.navigationController popViewControllerUsingTransition:transition];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapView {
    if (movies.count == 0 && people.count == 0) {
        [self cancelPress];
    }
}

- (void)requestPress {
    NSLog(@"request");
    self.transitioningDelegate = [STPTransitionCenter sharedInstance];
    
    RequestViewController *request = [[RequestViewController alloc] init];
    request.passedTitle = searchBarView.textField.text;
    NSLog(@"search text: %@", searchBarView.textField.text);

    STPBlockTransition *transition = [STPBlockTransition transitionWithAnimation:^(UIView *fromView, UIView *toView, UIView *containerView, void(^executeOnComplete)(BOOL finished)) {
        [containerView addSubview:toView];
        
        [request animateInCompletion:executeOnComplete origin:[self.view convertPoint:hideRequestButtonView.center fromView:hideRequestButtonView.superview]];
    }];
    
    
    [self presentViewController:request usingTransition:transition onCompletion:nil];
}

- (void)hideRequest:(BOOL)hide {
    hideRequestButtonView.alpha = (hide)?0.0f:1.0f;
}

- (void)reloadTable {
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSLog(@"can load more movies: %@", (canLoadMoreMovies)?@"YES":@"NO");
        return (canLoadMoreMovies)?movies.count + 1:movies.count;
    } else {
        return people.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == movies.count) {
            //load more cell
            return [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
        } else {
            MovieSearchTableViewCell *cell = (MovieSearchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            TMDBMovie *movie = (TMDBMovie*)movies[indexPath.row];
            
            [self setCorrectStatusOnCell:cell movie:movie];
            
            cell.titleLabel.text = [movie displayTitle];
            cell.yearLabel.text = [[TMDBHelper sharedInstance] yearForString:movie.releaseDate];
            if (movie.posterPath && ![movie.posterPath isEqualToString:@""]) {
                [cell setImageURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"]];
                [cell.imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"blankPoster"];
            }
            
            //    OCMovie *movie = (OCMovie*)movies[indexPath.row];
            //    cell.titleLabel.text = movie.title;
            //    [cell setImageURL:[[OnConnectHelper sharedInstance] urlForImageResource:movie.posterPath size:@"w92"]];
            
            return cell;
        }
    } else {
        PersonSearchTableViewCell *cell = (PersonSearchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"personCell"];
        
        TMDBPerson *person = (TMDBPerson *)people[indexPath.row];
        cell.titleLabel.text = person.name;
        if (person.profilePath && ![person.profilePath isEqualToString:@""]) {
            [cell.imageView sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:person.profilePath size:@"w92"] placeholderImage:[UIImage imageNamed:@"blankUser"]];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"blankUser"];
        }
        
        return cell;
    }
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header;

    header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    if (![header viewWithTag:101]) {
        header.contentView.backgroundColor = [UIColor clearColor];
        
        header.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
        header.backgroundView.backgroundColor = UIColorFromRGB(0x1e2227);
        header.backgroundView.alpha = 0.0f;
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
        background.backgroundColor = UIColorFromRGB(0x1e2227);
        background.alpha = .7f;
        [header.contentView addSubview:background];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.frame.size.width - 20, 30)];
        label.textColor = [UIColor whiteColor];
        label.tag = 101;
        label.backgroundColor = [UIColor clearColor];
        [header.contentView addSubview:label];
    }

    NSString *title;
    switch (section) {
        case 1:
            title = @"People"; break;
        default: title = @""; break;
    }
    [(UILabel *)[header viewWithTag:101] setText:title];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 && people.count > 0) {
        return 30;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == movies.count) {
            //load more
            [self loadPage:currentLoadedPage + 1 done:^{
                currentLoadedPage++;
            }error:^{
                
            }];
        } else {
            selectedMovie = movies[indexPath.row];
            [self performSegueWithIdentifier:@"toMovie" sender:self];
        }
    } else {
        selectedPerson = people[indexPath.row];
        [self performSegueWithIdentifier:@"toPerson" sender:self];
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [searchBarView.textField resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView scrollViewDidScroll:scrollView];
}

- (void)loadPage:(int)page done:(SuccessBlock)done error:(SuccessBlock)error {
    [[TMDBHelper sharedInstance] moviesForSearch:searchBarView.textField.text page:page success:^(NSArray *results, int totalPages) {
        int oldNumberOfRows = (int)movies.count;
        
        if (totalPages == currentLoadedPage + 1) {
            canLoadMoreMovies = NO;
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:movies.count inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            canLoadMoreMovies = YES;
        }
        
        movies = [movies arrayByAddingObjectsFromArray:results];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (int i = oldNumberOfRows; i < movies.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithArray:indexPaths] withRowAnimation:UITableViewRowAnimationFade];
        
        done();
    }error:^(NSError *err) {
        error();
    }];
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == tapViewGesture && (movies.count != 0 || people.count != 0)) {
        return NO;
    }
    
    return YES;
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
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.transitioningDelegate = nil;
    self.navigationController.delegate = nil;
}

- (void)makeTableFooter {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    
    hideRequestButtonView = [[UIView alloc] initForAutoLayout];
    hideRequestButtonView.backgroundColor = UIColorFromRGB(grayColor);
    hideRequestButtonView.layer.cornerRadius = 5.0f;
    [self.tableView.tableFooterView addSubview:hideRequestButtonView];
    
    [hideRequestButtonView autoSetDimension:ALDimensionWidth toSize:200 relation:NSLayoutRelationGreaterThanOrEqual];
    [hideRequestButtonView autoSetDimension:ALDimensionHeight toSize:30];
    [hideRequestButtonView autoAlignAxis:ALAxisVertical toSameAxisOfView:hideRequestButtonView.superview];
    [hideRequestButtonView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:hideRequestButtonView.superview withOffset:-15.0f];
    
    UIView *container = [[UIView alloc] initForAutoLayout];
    [hideRequestButtonView addSubview:container];
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
    label.text = @"Request Film";
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(requestPress)];
    [self.tableView.tableFooterView addGestureRecognizer:tap];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.tabBarController.navigationItem.hidesBackButton = YES;
    self.navigationItem.hidesBackButton = YES;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
    searchBarView = [[SearchBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20, 40)];
    searchBarView.delegate = self;
    [searchBarView.cancelButton addTarget:self action:@selector(cancelPress) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = searchBarView;
    
    self.tableView.continuousDelegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    [self makeTableFooter];
    
    self.view.backgroundColor = [UIColor clearColor];

    tapViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    tapViewGesture.delegate = self;
    [self.view addGestureRecognizer:tapViewGesture];
    
    [searchBarView.textField becomeFirstResponder];
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:parseDidAddMovieToWatchlistNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:parseDidAddMovieToSeenNotification object:nil];
//    [searchBar becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [searchBarView.textField resignFirstResponder];
    
    if ([segue.identifier isEqualToString:@"toMovie"]) {
        MovieViewController *destination = (MovieViewController*)segue.destinationViewController;
        destination.movie = selectedMovie;
    } else if ([segue.identifier isEqualToString:@"toPerson"]) {
        PersonViewController *destination = (PersonViewController*)segue.destinationViewController;
        destination.person = selectedPerson;
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
