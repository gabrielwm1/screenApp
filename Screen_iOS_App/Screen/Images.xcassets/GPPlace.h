//
//  GPPlace.h
//  Screen
//
//  Created by Mason Wolters on 11/15/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "GPPhoto.h"

@interface GPPlace : NSObject

@property (strong, nonatomic) NSDictionary *geometry;
@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSString *rating;

+ (NSDictionary *)searchMappings;
+ (RKObjectMapping *)searchMapping;

@end
