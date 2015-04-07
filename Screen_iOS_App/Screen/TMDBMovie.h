//
//  TMDBMovie.h
//  Screen
//
//  Created by Mason Wolters on 11/7/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "TMDBTrailer.h"
#import "TMDBCast.h"
#import "TMDBCrew.h"

@interface TMDBMovie : NSObject

//Search Movie
@property (strong, nonatomic) NSString *adult;
@property (strong, nonatomic) NSString *backdropPath;
@property (strong, nonatomic) NSString *tmdbId;
@property (strong, nonatomic) NSString *originalTitle;
@property (strong, nonatomic) NSString *releaseDate;
@property (strong, nonatomic) NSString *posterPath;
@property (strong, nonatomic) NSString *popularity;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *voteAverage;
@property (strong, nonatomic) NSString *voteCount;

//Full Movie
@property (strong, nonatomic) NSString *budget;
@property (strong, nonatomic) NSDictionary *genres;
@property (strong, nonatomic) NSString *homepage;
@property (strong, nonatomic) NSString *imdbId;
@property (strong, nonatomic) NSString *overview;
@property (strong, nonatomic) NSDictionary *productionCompanies;
@property (strong, nonatomic) NSDictionary *productionCountries;
@property (strong, nonatomic) NSString *revenue;
@property (strong, nonatomic) NSString *runtime;
@property (strong, nonatomic) NSDictionary *spokenLanguages;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *tagline;
@property (strong, nonatomic) NSArray *youtubeTrailers;
@property (strong, nonatomic) NSArray *cast;
@property (strong, nonatomic) NSArray *crew;
@property (strong, nonatomic) NSArray *similar;

@property (strong, nonatomic) NSString *rottenTomatoesScore;

- (TMDBTrailer *)officialTrailer;
- (NSArray *)directors;

+ (NSDictionary *)searchMappings;
+ (NSDictionary *)fullMappings;

+ (RKObjectMapping *)searchMapping;
+ (RKObjectMapping *)fullMapping;

- (NSString *)displayTitle;

@end
