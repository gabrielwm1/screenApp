//
//  TMDBPerson.m
//  Screen
//
//  Created by Mason Wolters on 11/12/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TMDBPerson.h"

@implementation TMDBPerson

+ (NSDictionary *)mappings {
    return @{
             @"id": @"personId",
             @"name": @"name",
             @"popularity": @"popularity",
             @"profile_path": @"profilePath"
             };
}

+ (NSDictionary *)fullMappings {
    return @{
             @"adult": @"adult",
             @"also_known_as": @"alsoKnownAs",
             @"biography": @"biography",
             @"birthday": @"birthday",
             @"deathday": @"deathday",
             @"homepage": @"homepage",
             @"id": @"personId",
             @"name": @"name",
             @"place_of_birth": @"placeOfBirth",
             @"profile_path": @"profilePath"
             };
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[TMDBPerson class]];
    
    [mapping addAttributeMappingsFromDictionary:[TMDBPerson mappings]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"known_for" toKeyPath:@"knownFor" withMapping:[TMDBMovie searchMapping]]];
    
    return mapping;
}

+ (RKObjectMapping *)fullMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[TMDBPerson class]];
    
    [mapping addAttributeMappingsFromDictionary:[TMDBPerson fullMappings]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"movie_credits.cast" toKeyPath:@"asCast" withMapping:[TMDBMovie searchMapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"movie_credits.crew" toKeyPath:@"asCrew" withMapping:[TMDBMovie searchMapping]]];
    
    return mapping;
}

@end
