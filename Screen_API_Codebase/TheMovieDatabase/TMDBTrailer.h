//
//  TMDBTrailer.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface TMDBTrailer : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString *type;

+ (NSDictionary *)mappings;
+ (RKObjectMapping *)mapping;

@end
