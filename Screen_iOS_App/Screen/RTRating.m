//
//  RTRating.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "RTRating.h"

@implementation RTRating

+ (NSDictionary *)mappings {
    return @{
             @"critics_rating": @"criticsRating",
             @"critics_score": @"criticsScore",
             @"audience_rating": @"audienceRating",
             @"audience_score": @"audienceScore"
             };
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RTRating class]];
    [mapping addAttributeMappingsFromDictionary:[RTRating mappings]];
    return mapping;
}

@end
