//
//  OCTheater.m
//  Screen
//
//  Created by Mason Wolters on 12/2/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "OCTheater.h"

@implementation OCTheater

- (float)getLatitude {
    if (self.location && [self.location objectForKey:@"geoCode"] && [[self.location objectForKey:@"geoCode"] objectForKey:@"latitude"]) {
        return [self.location[@"geoCode"][@"latitude"] floatValue];
    } else {
        return MAXFLOAT;
    }
}

- (float)getLongitude {
    if (self.location && [self.location objectForKey:@"geoCode"] && [[self.location objectForKey:@"geoCode"] objectForKey:@"longitude"]) {
        return [self.location[@"geoCode"][@"longitude"] floatValue];
    } else {
        return MAXFLOAT;
    }
}

- (float)getDistance {
    if (self.location && [self.location objectForKey:@"distance"]) {
        return [self.location[@"distance"] floatValue];
    } else {
        return MAXFLOAT;
    }
}

+ (NSDictionary *)searchMappings {
    return @{
             @"theatreId": @"theaterId",
             @"name": @"name",
             @"location": @"location",
             @"location.address": @"address"
             };
}

+ (RKObjectMapping *)searchMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[OCTheater class]];
    [mapping addAttributeMappingsFromDictionary:[OCTheater searchMappings]];
    return mapping;
}

+ (NSDictionary *)nowPlayingMappings {
    return @{
             @"id": @"theaterId",
             @"name": @"name",
             @"address": @"address"
             };
}

+ (RKObjectMapping *)nowPlayingMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[OCTheater class]];
    [mapping addAttributeMappingsFromDictionary:[OCTheater nowPlayingMappings]];
    return mapping;
}

@end
