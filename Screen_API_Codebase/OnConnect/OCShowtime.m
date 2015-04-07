//
//  OCShowtime.m
//  Screen
//
//  Created by Mason Wolters on 12/3/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "OCShowtime.h"

@implementation OCShowtime

+ (NSDictionary *)mappings {
    return @{
             @"dateTime": @"dateTime",
             @"ticketURI": @"ticketURI"
             };
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[OCShowtime class]];
    
    [mapping addAttributeMappingsFromDictionary:[OCShowtime mappings]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"theatre" toKeyPath:@"theater" withMapping:[OCTheater nowPlayingMapping]]];
    
    return mapping;
}

@end
