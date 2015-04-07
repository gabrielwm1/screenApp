//
//  TMDBCrew.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>

@interface TMDBCrew : NSObject

@property (strong, nonatomic) NSString *creditId;
@property (strong, nonatomic) NSString *department;
@property (strong, nonatomic) NSString *crewId;
@property (strong, nonatomic) NSString *job;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *profilePath;

+ (NSDictionary *)mappings;

+ (RKObjectMapping *)mapping;

@end
