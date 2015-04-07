//
//  OCVideo.m
//  Screen
//
//  Created by Mason Wolters on 2/20/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "OCVideo.h"

@implementation OCVideo

+ (NSDictionary *)mappings {
    return @{
             @"id.text": @"objectId",
             @"host.text": @"host",
             @"url.text": @"url"
             };
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[OCVideo class]];
    
    [mapping addAttributeMappingsFromDictionary:[OCVideo mappings]];
    
    return mapping;
}

@end
