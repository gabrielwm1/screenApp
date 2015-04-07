//
//  LocationHelper.h
//  Screen
//
//  Created by Mason Wolters on 11/11/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^LocationBlock)(CLLocation *location);
typedef void(^ErrorBlock)(NSError *error);

@interface LocationHelper : NSObject <CLLocationManagerDelegate> {
    CLLocation *mostRecent;
    LocationBlock successBlock;
    ErrorBlock errorBlock;
}

@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)getCurrentLocation:(LocationBlock)success error:(ErrorBlock)error;

- (void)getLocationUserWants:(LocationBlock)success error:(ErrorBlock)error;

+ (LocationHelper *)sharedInstance;

- (void)requestAuthorizationIfNeeded;

@end
