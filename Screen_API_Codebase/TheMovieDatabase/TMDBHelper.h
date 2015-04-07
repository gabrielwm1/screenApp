//
//  TMDBHelper.h
//  Screen
//
//  Created by Mason Wolters on 11/7/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "TMDBMovie.h"
#import "TMDBPerson.h"
#import "OnConnectHelper.h"
#import "StringNormalizer.h"

typedef void(^ArrayBlock)(NSArray *array);
typedef void(^SearchBlock)(NSArray *array, int totalPages);
typedef void(^MovieBlock)(TMDBMovie *movie);
typedef void(^PersonBlock)(TMDBPerson *person);
typedef void(^BoolBlock)(BOOL isPlaying);
typedef void(^ErrorBlock)(NSError *error);

@interface TMDBHelper : NSObject {
    RKObjectManager *objectManager;
    NSArray *nowPlayingMovieIds;
}

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

- (void)moviesForSearch:(NSString *)search page:(int)page success:(SearchBlock)success error:(ErrorBlock)errorBlock;
- (void)movieForId:(NSString *)movieId success:(MovieBlock)success error:(ErrorBlock)errorBlock;
- (void)movieForImdbId:(NSString *)imdbId success:(MovieBlock)success error:(ErrorBlock)errorBlock;
- (void)movieForOCMovie:(OCMovie *)oc success:(MovieBlock)success error:(ErrorBlock)errorBlock;
- (void)movieIsNowPlaying:(TMDBMovie *)movie success:(BoolBlock)success error:(ErrorBlock)errorBlock;

- (void)peopleForSearch:(NSString *)search success:(ArrayBlock)success error:(ErrorBlock)errorBlock;
- (void)personForId:(NSString *)personId success:(PersonBlock)success error:(ErrorBlock)errorBlock;

- (NSURL *)urlForImageResource:(NSString *)image size:(NSString *)size;

- (NSDate *)dateFromString:(NSString *)string;
- (NSString *)formattedDateFromString:(NSString *)string;
- (NSString *)yearForString:(NSString *)string;

+ (TMDBHelper *)sharedInstance;

@end
