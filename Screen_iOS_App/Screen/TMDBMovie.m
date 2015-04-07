//
//  TMDBMovie.m
//  Screen
//
//  Created by Mason Wolters on 11/7/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TMDBMovie.h"

@implementation TMDBMovie

- (NSString *)displayTitle {
    if (self.originalTitle && ![self.originalTitle isEqualToString:self.title]) {
        return [NSString stringWithFormat:@"%@ (%@)", self.title, self.originalTitle];
    } else {
        return self.title;
    }
}

- (TMDBTrailer *)officialTrailer {
    NSMutableArray *trailers = [NSMutableArray array];
    
    for (TMDBTrailer *trailer in self.youtubeTrailers) {
        if ([trailer.type isEqualToString:@"Trailer"]) {
            [trailers addObject:trailer];
        }
    }
    
    TMDBTrailer *trailer = nil;
    
    for (TMDBTrailer *trail in trailers) {
        NSLog(@"%@", trail.name);
        if (!trailer && [trail.name containsString:@"Official"]) {
            trailer = trail;
        }
    }
    
    if (!trailer && trailers.count > 0) {
        trailer = trailers[0];
    }
    
    return trailer;
}

- (NSArray *)directors {
    NSMutableArray *directors = [NSMutableArray array];
    
    for (TMDBCrew *c in self.crew) {
        if ([c.job isEqualToString:@"Director"]) {
            [directors addObject:c];
        }
    }
    
    return [NSArray arrayWithArray:directors];
}

+ (NSDictionary *)searchMappings {
    return @{
             @"adult": @"adult",
             @"backdrop_path": @"backdropPath",
             @"id": @"tmdbId",
             @"original_title": @"originalTitle",
             @"release_date": @"releaseDate",
             @"poster_path": @"posterPath",
             @"popularity": @"popularity",
             @"title": @"title",
             @"vote_average": @"voteAverage",
             @"vote_count": @"voteCount"
             };
}

+ (NSDictionary *)fullMappings {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[TMDBMovie searchMappings]];
    [dict addEntriesFromDictionary:@{
                                     @"budget": @"budget",
                                     @"genres": @"genres",
                                     @"homepage": @"homepage",
                                     @"imdb_id": @"imdbId",
                                     @"overview": @"overview",
                                     @"production_companies": @"productionCompanies",
                                     @"production_countries": @"productionCountries",
                                     @"revenue": @"revenue",
                                     @"runtime": @"runtime",
                                     @"spoken_languages": @"spokenLanguages",
                                     @"status": @"status",
                                     @"tagline": @"tagline"
                                     }];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (RKObjectMapping *)searchMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[TMDBMovie class]];
    [mapping addAttributeMappingsFromDictionary:[TMDBMovie searchMappings]];
    return mapping;
}

+ (RKObjectMapping *)fullMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[TMDBMovie class]];
    [mapping addAttributeMappingsFromDictionary:[TMDBMovie fullMappings]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"trailers.youtube" toKeyPath:@"youtubeTrailers" withMapping:[TMDBTrailer mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"credits.cast" toKeyPath:@"cast" withMapping:[TMDBCast mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"credits.crew" toKeyPath:@"crew" withMapping:[TMDBCrew mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"similar.results" toKeyPath:@"similar" withMapping:[TMDBMovie searchMapping]]];
    
    return mapping;
}

@end
