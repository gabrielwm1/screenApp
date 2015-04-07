//
//  Movie.m
//  Screen
//
//  Created by Mason Wolters on 11/6/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "RTMovie.h"

@implementation RTMovie

+ (NSDictionary *)mappings {
    return @{
             @"id" :@"objectId",
             @"title": @"title",
             @"year": @"year",
             @"mpaa_rating": @"mpaaRating",
             @"runtime": @"runtime",
             @"critics_consensus": @"criticsConsensus",
             @"release_dates": @"releaseDates",
             @"synopsis": @"synopsis",
             @"posters": @"posters",
             @"abridged_cast": @"abridgedCast",
             @"alternate_ids": @"alternateIds",
             @"links": @"links"
             };
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RTMovie class]];
    [mapping addAttributeMappingsFromDictionary:[self mappings]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ratings" toKeyPath:@"ratings" withMapping:[RTRating mapping]]];
    return mapping;
}

@end
