//
//  TMDBTrailer.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TMDBTrailer.h"

@implementation TMDBTrailer

+ (NSDictionary *)mappings {
    return @{
             @"name": @"name",
             @"size": @"size",
             @"source": @"source",
             @"type": @"type"
             };
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[TMDBTrailer class]];
    [mapping addAttributeMappingsFromDictionary:[TMDBTrailer mappings]];
    return mapping;
}



@end
