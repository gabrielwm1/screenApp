//
//  LocationHelper.m
//  Screen
//
//  Created by Mason Wolters on 11/11/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "LocationHelper.h"

@implementation LocationHelper

@synthesize locationManager;

#pragma mark - Public

- (void)getCurrentLocation:(LocationBlock)success error:(ErrorBlock)error {
    if (mostRecent) {
        success(mostRecent);
    } else {
        successBlock = success;
        errorBlock = error;
        [locationManager startUpdatingLocation];
    }
}

- (void)getLocationUserWants:(LocationBlock)success error:(ErrorBlock)error {
    NSNumber *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchLatitude"];
    NSNumber *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchLongitude"];
    if (latitude && longitude) {
        success([[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue]);
    } else {
        [self getCurrentLocation:^(CLLocation *loc) {
            success(loc);
        }error:errorBlock];
    }
}

- (void)requestAuthorizationIfNeeded {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    } 
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    mostRecent = [locations lastObject];
    NSLog(@"did update location lat: %f, long: %f", mostRecent.coordinate.latitude, mostRecent.coordinate.longitude);
    [manager stopUpdatingLocation];
    
    if (successBlock) {
        errorBlock = nil;
        successBlock(mostRecent);
        successBlock = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"location manager did fail: %@", error.description);
    if (errorBlock) {
        successBlock = nil;
        errorBlock(error);
        errorBlock = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"did change authorization status: %d", status);
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [locationManager requestWhenInUseAuthorization];
        }
        [locationManager startUpdatingLocation];
        NSLog(@"start updating location");
    }
    
    return self;
}

+ (LocationHelper *)sharedInstance {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

@end
