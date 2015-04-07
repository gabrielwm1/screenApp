//
//  PFCast.m
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "PFCast.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFCast

@dynamic castId;
@dynamic character;
@dynamic creditId;
@dynamic tmdbCastId;
@dynamic name;
@dynamic order;
@dynamic profilePath;

+ (NSString *)parseClassName {
    return @"Cast";
}

+ (void)load {
    [self registerSubclass];
}

@end
