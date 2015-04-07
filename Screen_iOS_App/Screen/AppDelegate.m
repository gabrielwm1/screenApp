//
//  AppDelegate.m
//  Screen
//
//  Created by Mason Wolters on 11/6/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "AppDelegate.h"
#import "TMDBHelper.h"
#import "MovieViewController.h"
#import "WatchlistsViewController.h"
#import "ParseHelper.h"
#import "WToast.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize landscapeOnlyOrientation;

@synthesize movieDidDismiss;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Fabric with:@[CrashlyticsKit, TwitterKit]];
    
    [Parse setApplicationId:@"sh5TWSiKn9Dmljgv0gJ5MiqrvTUxzE7BHP3kluUH"
                  clientKey:@"Hy4LqCyGZXAPUaUnGyXqiCMO2B1h6bzDvPgYly3m"];
    
    [PFTwitterUtils initializeWithConsumerKey:@"R389bZJQcKqsjK9igqFKH9yiU" consumerSecret:@"9CPqg1IXkMd6x2sr48pjpSTCfd5N0XrpYq8hCvqaQvmzjVKHfi"];
    [PFFacebookUtils initializeFacebook];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"hasLaunched"]) {
        //has not launched yet
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"hasLaunched"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:10.0f] forKey:@"theaterRadius"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"searchLocation"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"searchLocationName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if ([PFUser currentUser]) {
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *user, NSError *error) {
            [[ParseHelper sharedInstance] checkForNewShowtimesOnWatchlist:^(NSArray *alerts) {
                NSLog(@"ALERT FOR %i MOVIES!", (int)alerts.count);
                if (alerts.count > 0 && !hasAlerted) {
                    
                    [WToast showWithText:[NSString stringWithFormat:@"%i movie%@ on watchlist are now playing nearby!", (int)alerts.count, (alerts.count > 1)?@"s":@""] duration:4 roundedCorners:YES];
                    
                    UITabBarController *tabBarController = (UITabBarController *)[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController];
                    [(UITabBarItem *)tabBarController.tabBar.items[1] setBadgeValue:[NSString stringWithFormat:@"%i", (int)alerts.count]];
                    
                    hasAlerted = YES;
                }
            }error:^(NSError *error) {
                
            }];
        }];
    }
    
    return YES;
}

- (void)moviePlayerNotification:(NSNotification *)notification {
    NSLog(@"video stopped playing?");
    movieDidDismiss = YES;
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([self.window.rootViewController.presentedViewController isKindOfClass:[XCDYouTubeVideoPlayerViewController class]] && !movieDidDismiss) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[url host] isEqualToString:@"movie"]) {
        NSDictionary *query = [self parseQueryString:[url query]];
        
        if ([query objectForKey:@"id"]) {
            [[TMDBHelper sharedInstance] movieForId:[query objectForKey:@"id"] success:^(TMDBMovie *movie) {
                UITabBarController *root = (UITabBarController *)self.window.rootViewController;
                [root dismissViewControllerAnimated:YES completion:nil];
                [root setSelectedIndex:0];
                
                UINavigationController *watchlistNav = (UINavigationController *)root.viewControllers[0];
                [watchlistNav popToRootViewControllerAnimated:NO];
                
                WatchlistsViewController *watchlists = watchlistNav.viewControllers[0];
                [watchlists gotoMovie:movie];
            }error:^(NSError *error) {
                
            }];
        }
    }
    
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];
}

@end
