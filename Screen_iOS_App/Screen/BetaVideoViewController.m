//
//  BetaVideoViewController.m
//  Screen
//
//  Created by Mason Wolters on 2/8/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "BetaVideoViewController.h"
#import "WatchlistsViewController.h"

@interface BetaVideoViewController ()

@end

@implementation BetaVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    WatchlistsViewController *watchlists = (WatchlistsViewController *)[[self.tabBarController.viewControllers[0] viewControllers] objectAtIndex:0];
    [watchlists playVideo];
    [self.tabBarController setSelectedIndex:0];
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
