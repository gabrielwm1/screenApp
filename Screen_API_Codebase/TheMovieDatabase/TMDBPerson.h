//
//  TMDBPerson.h
//  Screen
//
//  Created by Mason Wolters on 11/12/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "TMDBMovie.h"

@interface TMDBPerson : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *popularity;
@property (strong, nonatomic) NSString *profilePath;
@property (strong, nonatomic) NSString *personId;
@property (strong, nonatomic) NSArray *knownFor;

@property (strong, nonatomic) NSString *adult;
@property (strong, nonatomic) NSString *alsoKnownAs;
@property (strong, nonatomic) NSString *biography;
@property (strong, nonatomic) NSString *birthday;
@property (strong, nonatomic) NSString *deathday;
@property (strong, nonatomic) NSString *homepage;
@property (strong, nonatomic) NSString *placeOfBirth;
@property (strong, nonatomic) NSArray *asCast;
@property (strong, nonatomic) NSArray *asCrew;

+ (NSDictionary *)mappings;
+ (NSDictionary *)fullMappings;

+ (RKObjectMapping *)mapping;
+ (RKObjectMapping *)fullMapping;

@end
