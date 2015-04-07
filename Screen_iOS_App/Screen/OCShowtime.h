//
//  OCShowtime.h
//  Screen
//
//  Created by Mason Wolters on 12/3/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCTheater.h"
#import <RestKit/RestKit.h>

@interface OCShowtime : NSObject

@property (strong, nonatomic) NSString *dateTime;
@property (strong, nonatomic) NSString *ticketURI;
@property (strong, nonatomic) OCTheater *theater;

+ (NSDictionary *)mappings;
+ (RKObjectMapping *)mapping;

@end
