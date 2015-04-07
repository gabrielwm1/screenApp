//
//  GPPlace.m
//  Screen
//
//  Created by Mason Wolters on 11/15/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "GPPlace.h"

@implementation GPPlace

+ (NSDictionary *)searchMappings {
    return @{
             @"geometry": @"geometry",
             @"icon": @"icon",
             @"place_id": @"placeId",
             @"name": @"name",
             @"rating": @"rating"
             };
}

+ (RKObjectMapping *)searchMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[GPPlace class]];
    
    [mapping addAttributeMappingsFromDictionary:[GPPlace searchMappings]];
    
    RKRelationshipMapping *photo = [RKRelationshipMapping relationshipMappingFromKeyPath:@"photos" toKeyPath:@"photos" withMapping:[GPPhoto mapping]];
    [mapping addPropertyMapping:photo];
    
    return mapping;
}

@end
