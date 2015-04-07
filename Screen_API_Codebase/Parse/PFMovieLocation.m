//
//  PFMovieLocation.m
//  Screen
//
//  Created by Mason Wolters on 11/11/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "PFMovieLocation.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFMovieLocation

@synthesize movie;
@synthesize user;
@synthesize location;
@synthesize movieId;

+ (NSString *)parseClassName {
    return @"MovieLocation";
}

+ (void)load {
    [self registerSubclass];
}

@end
