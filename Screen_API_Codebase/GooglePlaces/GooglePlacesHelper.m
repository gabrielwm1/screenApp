//
//  GPHelper.m
//  Screen
//
//  Created by Mason Wolters on 11/15/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "GooglePlacesHelper.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesPlaceDetailQuery.h"
#import "LocationHelper.h"

@implementation GooglePlacesHelper

const NSString *gPApiKey = @"AIzaSyA2uEVqUU9YKdqF0wmovpnLgpT131SXqEU";
const NSString *gPBaseUrl = @"/maps/api/place";

@synthesize searchQuery = _searchQuery;

- (SPGooglePlacesAutocompleteQuery *)searchQuery {
    if (!_searchQuery) {
        _searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
        _searchQuery.radius = 100000.0f;
        _searchQuery.language = @"en";
        _searchQuery.types = SPPlaceTypeGeocode;
    }
    
    return _searchQuery;
}

#pragma mark - Private

- (NSString *)path:(NSString *)path {
    return [NSString stringWithFormat:@"%@%@", gPBaseUrl, path];
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}


#pragma mark - Public

- (void)theatersWithinRadius:(float)radius ofLocation:(CLLocation *)location success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    
    NSDictionary *queryParams = @{
                                  @"key": gPApiKey,
                                  @"location": [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude],
                                  @"radius": [NSString stringWithFormat:@"%f", radius],
                                  @"types": @"movie_theater"
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/nearbysearch/json"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        success(result.array);
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
    
}

- (void)findTheaterWithName:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude success:(PlaceBlock)success error:(ErrorBlock)errorBlock {
    NSDictionary *queryParams = @{
                                  @"key": gPApiKey,
                                  @"location": [NSString stringWithFormat:@"%@,%@", latitude, longitude],
                                  @"radius": @"200",
                                  @"name": name
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/nearbysearch/json"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if (result.count > 0) {
            success(result.array[0]);
        } else {
            errorBlock(nil);
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

- (void)searchSuggestionsForQuery:(NSString *)query success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    ArrayErrorBlock searchBlock = ^(NSArray *places, NSError *error) {
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch places");
            errorBlock(error);
        } else {
            success(places);
        }
    };
    
    [self.searchQuery setInput:query];
    
    [[LocationHelper sharedInstance] getCurrentLocation:^(CLLocation *location) {
        self.searchQuery.location = location.coordinate;
        self.searchQuery.radius = 100000.0f;
        [self.searchQuery fetchPlaces:searchBlock];
    }error:^(NSError *error) {
        self.searchQuery.location = CLLocationCoordinate2DMake(0, 0);
        self.searchQuery.radius = 20000000;
        [self.searchQuery fetchPlaces:searchBlock];
    }];
}

- (NSURL *)urlForPhotoReference:(NSString *)photoReference maxWidth:(int)maxWidth {
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?key=%@&photoreference=%@&maxwidth=%i", gPApiKey, photoReference, maxWidth];
    NSLog(@"url: %@", url);
    return [NSURL URLWithString:url];
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    if (self) {
        NSURL *base = [NSURL URLWithString:@"https://maps.googleapis.com"];
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:base];
        
        objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
        
        RKResponseDescriptor *searchDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[GPPlace searchMapping] method:RKRequestMethodGET pathPattern:[self path:@"/nearbysearch/json"] keyPath:@"results" statusCodes:[NSIndexSet indexSetWithIndex:200]];
        [objectManager addResponseDescriptor:searchDescriptor];
        
        
    }
    
    return self;
}

+ (GooglePlacesHelper *)sharedInstance {
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
