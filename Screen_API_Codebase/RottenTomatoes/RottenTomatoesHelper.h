//
//  RottenTomatoesAPI.h
//  Screen
//
//  Created by Mason Wolters on 11/6/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "RTMovie.h"
#import "RTRating.h"

typedef void(^ArrayBlock)(NSArray *array);
typedef void(^ArrayAndCountBlock)(NSArray *array, int totalPages);
typedef void(^RTMovieBlock)(RTMovie *movie);
typedef void(^ErrorBlock)(NSError *error);

@interface RottenTomatoesHelper : NSObject {
    RKObjectManager *objectManager;
}

- (id)init;

- (void)loadMovies:(ArrayBlock)success error:(ErrorBlock)errorBlock;
- (void)moviesForSearch:(NSString *)search page:(int)page success:(ArrayBlock)success error:(ErrorBlock)errorBlock;
- (void)boxOfficeMovies:(ArrayBlock)success errorBlock:(ErrorBlock)errorBlock;
- (void)moviesInTheatersPage:(int)page success:(ArrayAndCountBlock)success errorBlock:(ErrorBlock)errorBlock;
- (void)openingMovies:(ArrayBlock)success errorBlock:(ErrorBlock)errorBlock;
- (void)movieForIMDBId:(NSString *)imdbId success:(RTMovieBlock)success error:(ErrorBlock)errorBlock;

+ (RottenTomatoesHelper *)sharedInstance;

@end
