//
//  TMDBCrew.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TMDBCrew.h"

@implementation TMDBCrew

+ (NSDictionary *)mappings {
    return @{
             @"credit_id": @"creditId",
             @"department": @"department",
             @"id": @"crewId",
             @"job": @"job",
             @"name": @"name",
             @"profile_path": @"profilePath"
             };
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[TMDBCrew class]];
    [mapping addAttributeMappingsFromDictionary:[TMDBCrew mappings]];
    return mapping;
}



@end
