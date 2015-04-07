//
//  TabBarViewController.m
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TabBarViewController.h"
#import "Constants.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.tabBar.barTintColor = UIColorFromRGB(0x161a2b);
//    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.tintColor = UIColorFromRGB(blueColor);

    
    [self.tabBar setBackgroundImage:[UIImage new]];
    self.tabBar.shadowImage = [UIImage new];
    self.tabBar.translucent = YES;
    
    // set the selected colors
    [self.tabBar setTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    
    UIColor * unselectedColor = [UIColor whiteColor];
    
    // set color of unselected text
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:unselectedColor, NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateNormal];
    
    // generate a tinted unselected image based on image passed via the storyboard
    for(UITabBarItem *item in self.tabBar.items) {
        // use the UIImage category code for the imageWithColor: method
        item.image = [[item.selectedImage imageWithColor:unselectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    self.delegate = self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    for (id vc in self.viewControllers) {
        if ([vc isKindOfClass:[UINavigationController class]] && ![vc isEqual:viewController]) {
            [(UINavigationController *)vc popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:overrideRowHighlightNotification object:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)shouldAutorotate {
//    return NO;
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationPortrait;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
