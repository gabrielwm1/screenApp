//
//  TMDBCast.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TMDBCast.h"

@implementation TMDBCast

+ (NSDictionary *)mappings {
    return @{
             @"cast_id": @"castId",
             @"character": @"character",
             @"credit_id": @"creditId",
             @"id": @"tmdbCastId",
             @"name": @"name",
             @"order": @"order",
             @"profile_path": @"profilePath"
             };
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[TMDBCast class]];
    [mapping addAttributeMappingsFromDictionary:[TMDBCast mappings]];
    return mapping;
}

@end
