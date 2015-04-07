//
//  OnConnectHelper.h
//  Screen
//
//  Created by Mason Wolters on 11/10/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "OCMovie.h"
#import "OCVideo.h"
#import "TMDBMovie.h"
#import "LocationHelper.h"
#import "OCOrganizedShowtime.h"
#import "StringNormalizer.h"

@class PFMovie;

typedef void(^ArrayBlock)(NSArray *array);
typedef void(^DictionaryBlock)(NSDictionary *dictionary);
typedef void(^SearchBlock)(NSArray *array, int totalPages);
typedef void(^BoolBlock)(BOOL result);
typedef void(^OCMovieBlock)(OCMovie *movie);
typedef void(^ErrorBlock)(NSError *error);

extern int numberOfDaysShowtimes;

typedef enum VOD {
    vodNetflix,
    vodItunes,
    vodAmazon,
    vodYoutube,
    vodHulu,
    vodVudu,
    vodXfinity,
    vodFandor,
    vodCinemaNow,
    vodInvalid
} VOD;

@interface VODAvailability : NSObject

@property (nonatomic) VOD service;
@property (strong, nonatomic) NSString *link;

+ (VODAvailability *)vodAvailabilityWithHost:(NSString *)host link:(NSString *)link;
+ (VOD)vodForHost:(NSString *)string;

@end

@interface OnConnectHelper : NSObject {
    RKObjectManager *objectManager;
    RKObjectManager *socialObjectManager;
//    NSArray *showtimes;
    NSDateFormatter *timeFormatter;
    NSDateFormatter *dateFormatter;
    NSMutableDictionary *showtimesForRadius;
    NSMutableDictionary *theatersForRadius;
    NSMutableDictionary *lastLocations;
    NSDateFormatter *showtimesDateFormatter;
    
    NSArray *attributeKeys;
    NSArray *attributeTitles;
}

+ (OnConnectHelper *)sharedInstance;

- (NSURL *)urlForImageResource:(NSString *)image size:(NSString *)size;

- (void)moviesForSearch:(NSString *)search page:(int)page success:(SearchBlock)success error:(ErrorBlock)errorBlock;

- (void)moviesPlayingInRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

- (void)showtimesInRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

- (void)showTimesForMovie:(TMDBMovie *)movie inRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

- (void)showTimesForOCMovie:(OCMovie *)movie inRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

- (void)movieIsNowPlaying:(TMDBMovie *)movie success:(BoolBlock)success error:(ErrorBlock)errorBlock;

- (void)ocMovieForTMDBMovieInNowPlaying:(TMDBMovie *)movie success:(OCMovieBlock)success error:(ErrorBlock)errorBlock;

- (void)theaterDetailsInRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

- (void)showTimesForTheatersNearby:(DictionaryBlock)result error:(ErrorBlock)errorBlock;

- (void)showTimesForTheater:(OCTheater *)theater success:(ArrayBlock)success error:(ErrorBlock)error;

- (NSString *)timesStringForTimes:(NSArray *)times beforeNow:(BOOL)beforeNow;

- (NSMutableAttributedString *)attributedStringForTimes:(NSArray *)times beforeColor:(UIColor *)beforeColor afterColor:(UIColor *)afterColor;

- (NSString *)closestDatePlayingForShowtime:(OCOrganizedShowtime *)showtime;

- (BOOL)ocMovie:(OCMovie *)oc matchesTMDBMovie:(TMDBMovie *)tmdb;

- (BOOL)ocMovie:(OCMovie *)oc matchesPFMovie:(PFMovie *)pf;

- (void)ocMovieForTMDBMovie:(TMDBMovie *)tmdb success:(OCMovieBlock)success error:(ErrorBlock)errorBlock;

#pragma mark - VOD Availability

//EFFECTS: success array is array of VODAvailability
- (void)vodAvaiabilityForOCMovie:(OCMovie *)oc success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

//EFFECTS: success array is array of VODAvailability
- (void)vodAvailabilityForTMDBMovie:(TMDBMovie *)tmdb success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

- (void)voidShowtimes;

@end
