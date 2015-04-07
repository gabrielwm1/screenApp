//
//  GPHelper.h
//  Screen
//
//  Created by Mason Wolters on 11/15/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GPPlace.h"
#import "GPPhoto.h"
#import "SPGooglePlacesAutocompletePlace.h"

@class SPGooglePlacesAutocompleteQuery;

typedef void(^ArrayBlock)(NSArray *results);
typedef void(^PlaceBlock)(GPPlace *place);
typedef void(^ErrorBlock)(NSError *error);
typedef void(^ArrayErrorBlock)(NSArray *results, NSError *error);

@interface GooglePlacesHelper : NSObject {
    RKObjectManager *objectManager;
}

@property (strong, nonatomic) SPGooglePlacesAutocompleteQuery *searchQuery;

- (void)theatersWithinRadius:(float)radius ofLocation:(CLLocation *)location success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

- (void)findTheaterWithName:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude success:(PlaceBlock)success error:(ErrorBlock)errorBlock;

- (NSURL *)urlForPhotoReference:(NSString *)photoReference maxWidth:(int)maxWidth;

- (void)searchSuggestionsForQuery:(NSString *)query success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

+ (GooglePlacesHelper *)sharedInstance;

@end
