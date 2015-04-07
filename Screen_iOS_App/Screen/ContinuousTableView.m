//
//  ContinuousTableView.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "ContinuousTableView.h"

@implementation ContinuousTableView

@synthesize spinner;
@synthesize continuousDelegate;
@synthesize loading;
@synthesize currentPage;
@synthesize totalPages = _totalPages;

- (void)reloadData {
    [super reloadData];
    currentPage = 1;
    self.contentOffset = CGPointMake(0, 0);
    NSLog(@"reload data");
}

- (void)loadNextPage {
    NSLog(@"current page: %i, total pages: %i", currentPage, _totalPages);
    [spinner startAnimating];
    [continuousDelegate loadPage:currentPage+1 done:^{
        currentPage++;
        [spinner stopAnimating];
        loading = NO;
    } error:^{
        loading = NO;
        [spinner stopAnimating];
    }];
}

#pragma mark - TableView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0 && !loading && currentPage < _totalPages) {
        loading = YES;
        [self loadNextPage];
        NSLog(@"reached bottom");
    }
}

#pragma mark - Initialize

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!hasInitialized) {
        hasInitialized = YES;
        
        spinner.center = CGPointMake(self.frame.size.width/2, self.tableFooterView.frame.size.height/2);
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        
        spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce color:[UIColor blackColor]];
        spinner.spinnerSize = 25.0f;
        spinner.color = [UIColor whiteColor];
        [spinner stopAnimating];
        
        currentPage = 1;
        _totalPages = 1;
        
        [self.tableFooterView addSubview:spinner];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
