//
//  AppDelegate.h
//  Screen
//
//  Created by Mason Wolters on 11/6/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseHelper.h"
#import "LocationHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <TwitterKit/TwitterKit.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    BOOL hasAlerted;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL landscapeOnlyOrientation;
@property (nonatomic) BOOL movieDidDismiss;

@end

