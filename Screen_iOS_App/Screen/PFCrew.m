//
//  PFCrew.m
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "PFCrew.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFCrew

@dynamic creditId;
@dynamic department;
@dynamic crewId;
@dynamic job;
@dynamic name;
@dynamic profilePath;

+ (NSString *)parseClassName {
    return @"Crew";
}

+ (void)load {
    [self registerSubclass];
}

@end
