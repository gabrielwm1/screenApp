//
//  Movie.h
//  Screen
//
//  Created by Mason Wolters on 11/6/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "RTRating.h"

@interface RTMovie : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *mpaaRating;
@property (strong, nonatomic) NSString *runtime;
@property (strong, nonatomic) NSString *criticsConsensus;
@property (strong, nonatomic) NSDictionary *releaseDates;
@property (strong, nonatomic) RTRating *ratings;
@property (strong, nonatomic) NSString *synopsis;
@property (strong, nonatomic) NSDictionary *posters;
@property (strong, nonatomic) NSDictionary *abridgedCast;
@property (strong, nonatomic) NSDictionary *alternateIds;
@property (strong, nonatomic) NSDictionary *links;

+ (NSDictionary *)mappings;
+ (RKObjectMapping *)mapping;

@end
