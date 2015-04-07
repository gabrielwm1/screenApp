//
//  TMDBCast.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface TMDBCast : NSObject

@property (strong, nonatomic) NSString *castId;
@property (strong, nonatomic) NSString *character;
@property (strong, nonatomic) NSString *creditId;
@property (strong, nonatomic) NSString *tmdbCastId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *order;
@property (strong, nonatomic) NSString *profilePath;

+ (NSDictionary *)mappings;

+ (RKObjectMapping *)mapping;

@end
