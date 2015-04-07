//
//  DiscoverViewController.m
//  Screen
//
//  Created by Mason Wolters on 2/18/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "DiscoverViewController.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import "ParseHelper.h"
#import "Constants.h"

@interface DiscoverViewController ()

@end

@implementation DiscoverViewController


#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 40) duration:8.0f andFadeLength:10.0f];
    titleLabel.text = @"Discover";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
//    [[ParseHelper sharedInstance] movieReccommendations:^(NSArray *movies) {
//        NSLog(@"found %i movie reccommendations", movies.count);
//        for (PFMovie *movie in movies) {
//            NSLog(@"%@", movie.title);
//        }
//    }error:^(NSError *error) {
//        
//    }];
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
