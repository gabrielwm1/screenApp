//
//  GPPhoto.m
//  Screen
//
//  Created by Mason Wolters on 12/4/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "GPPhoto.h"

@implementation GPPhoto

+ (NSDictionary *)mappings {
    return @{
             @"photo_reference": @"photoReference",
             @"height": @"height",
             @"width": @"width"
             };
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[GPPhoto class]];
    
    [mapping addAttributeMappingsFromDictionary:[GPPhoto mappings]];
    
    return mapping;
}

@end
