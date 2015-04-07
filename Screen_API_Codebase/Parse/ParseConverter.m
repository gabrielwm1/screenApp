//
//  ParseConverter.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "ParseConverter.h"

@implementation ParseConverter

+ (PFMovie *)movieForTmdbMovie:(TMDBMovie *)mov {
    PFMovie *movie = (PFMovie*)[ParseConverter convertToPF:mov class:[PFMovie class]];
    
    movie.youtubeTrailers = nil;
    movie.cast = nil;
    movie.crew = nil;
    
//    NSMutableArray *trailers = [NSMutableArray array];
//    for (TMDBTrailer *trail in mov.youtubeTrailers) {
//        PFTrailer *trailer = (PFTrailer*)[ParseConverter convertToPF:trail class:[PFTrailer class]];
//        [trailers addObject:trailer];
//    }
//    
//    NSMutableArray *casts = [NSMutableArray array];
//    for (TMDBCast *ca in mov.cast) {
//        PFCast *cast = (PFCast *)[ParseConverter convertToPF:ca class:[PFCast class]];
//        [casts addObject:cast];
//    }
//    
//    NSMutableArray *crews = [NSMutableArray array];
//    for (TMDBCrew *cre in mov.crew) {
//        PFCrew *crew = (PFCrew *)[ParseConverter convertToPF:cre class:[PFCrew class]];
//        [crews addObject:crew];
//    }
//    
//    movie.youtubeTrailers = [NSArray arrayWithArray:trailers];
//    movie.cast = [NSArray arrayWithArray:casts];
//    movie.crew = [NSArray arrayWithArray:crews];

    return movie;
}

+ (TMDBMovie *)tmdbMovieForPFMovie:(PFMovie *)mov {
    TMDBMovie *movie = [ParseConverter convertToTmdb:mov class:[PFMovie class]];
    
    NSLog(@"old movie tmdb: %@", mov.tmdbId);
    NSLog(@"new movie tmdb: %@", movie.tmdbId);
    
    return movie;
}

+ (id)convertToTmdb:(id)object class:(Class)class {
    id tmdb = [class new];
    
    NSArray *properties = [ParseConverter propertyNamesForObject:object];
    
    for (NSString *property in properties) {
        if (![property isEqualToString:@"genres"] && ![property isEqualToString:@"productionCompanies"] && ![property isEqualToString:@"productionCountries"] && ![property isEqualToString:@"spokenLanguages"] && ![property isEqualToString:@"youtubeTrailers"] && ![property isEqualToString:@"cast"] && ![property isEqualToString:@"crew"] && ![property isEqualToString:@"similar"] && ![property isEqualToString:@"userCount"]) {
            [tmdb setValue:[object valueForKey:property] forKey:property];
            
        }
    }
    
    return tmdb;
}

+ (id)convertToPF:(id)object class:(Class)class {
    id pf = [class object];
    
    NSArray *properties = [ParseConverter propertyNamesForObject:object];
    
    for (NSString *property in properties) {
        if (![property isEqualToString:@"genres"] && ![property isEqualToString:@"productionCompanies"] && ![property isEqualToString:@"productionCountries"] && ![property isEqualToString:@"spokenLanguages"] && ![property isEqualToString:@"youtubeTrailers"] && ![property isEqualToString:@"cast"] && ![property isEqualToString:@"crew"] && ![property isEqualToString:@"similar"]) {
            [pf setValue:[object valueForKey:property] forKey:property];

        }
    }
    
    return pf;
}

+ (NSArray *)propertyNamesForObject:(id)object {
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([object class], &numberOfProperties);
    
    NSMutableArray *names = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        [names addObject:name];
    }
    free(propertyArray);
    
    return [NSArray arrayWithArray:names];
}

@end
