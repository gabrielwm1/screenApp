//
//  OCMovie.m
//  Screen
//
//  Created by Mason Wolters on 11/10/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "OCMovie.h"
#import "OCVideo.h"

@implementation OCMovie

+ (NSDictionary *)searchMappings {
    return @{
             @"program.title": @"title",
             @"program.preferredImage.uri" :@"posterPath",
             @"program.releaseYear": @"releaseYear",
             @"program.tmsId": @"tmsId",
             @"program.rootId": @"rootId"
             };
}

+ (RKObjectMapping *)searchMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[OCMovie class]];
    
    [mapping addAttributeMappingsFromDictionary:[OCMovie searchMappings]];
    
    return mapping;
}

+ (NSDictionary *)nowPlayingMappings {
    return @{
             @"tmsId": @"tmsId",
             @"rootId": @"rootId",
             @"title": @"title",
             @"preferredImage.uri": @"posterPath",
             @"releaseYear": @"releaseYear",
             @"longDescription": @"longDescription"
             };
}

+ (RKObjectMapping *)nowPlayingMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[OCMovie class]];
    
    [mapping addAttributeMappingsFromDictionary:[OCMovie nowPlayingMappings]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"showtimes" toKeyPath:@"showtimes" withMapping:[OCShowtime mapping]]];
    
    return mapping;
}

+ (NSDictionary *)vodMappings {
    return @{
             @"title.text": @"title",
             @"tmsId.text": @"tmsId",
             @"rootId.text": @"rootId"
             };
}

+ (RKObjectMapping *)vodMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[OCMovie class]];
    
    [mapping addAttributeMappingsFromDictionary:[OCMovie vodMappings]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"videos.video" toKeyPath:@"videos" withMapping:[OCVideo mapping]]];
    
    return mapping;
}

@end
