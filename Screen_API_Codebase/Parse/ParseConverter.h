//
//  ParseConverter.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ParseHelper.h"
#import "TMDBHelper.h"

@interface ParseConverter : NSObject

+ (NSArray *)propertyNamesForObject:(id)object;

+ (PFMovie*)movieForTmdbMovie:(TMDBMovie *)movie;

+ (TMDBMovie *)tmdbMovieForPFMovie:(PFMovie *)movie;

@end
