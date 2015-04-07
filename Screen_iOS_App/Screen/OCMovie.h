//
//  OCMovie.h
//  Screen
//
//  Created by Mason Wolters on 11/10/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>
#import "OCShowtime.h"

@interface OCMovie : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *posterPath;

@property (strong, nonatomic) NSString *tmsId;
@property (strong, nonatomic) NSString *rootId;
@property (strong, nonatomic) NSArray *showtimes;
@property (strong, nonatomic) NSString *releaseYear;
@property (strong, nonatomic) NSString *longDescription;
@property (strong, nonatomic) NSArray *videos;

+ (NSDictionary *)searchMappings;
+ (RKObjectMapping *)searchMapping;

+ (NSDictionary *)nowPlayingMappings;
+ (RKObjectMapping *)nowPlayingMapping;

+ (NSDictionary *)vodMappings;
+ (RKObjectMapping *)vodMapping;

@end
