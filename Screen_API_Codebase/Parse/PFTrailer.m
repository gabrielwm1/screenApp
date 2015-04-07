//
//  PFTrailer.m
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "PFTrailer.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFTrailer

@dynamic name;
@dynamic size;
@dynamic source;
@dynamic type;

+ (NSString *)parseClassName {
    return @"Trailer";
}

+ (void)load {
    [self registerSubclass];
}

@end
