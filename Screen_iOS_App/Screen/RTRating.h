//
//  RTRating.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface RTRating : NSObject

@property (strong, nonatomic) NSString *criticsRating;
@property (strong, nonatomic) NSString *criticsScore;
@property (strong, nonatomic) NSString *audienceRating;
@property (strong, nonatomic) NSString *audienceScore;

+ (NSDictionary *)mappings;

+ (RKObjectMapping *)mapping;

@end
