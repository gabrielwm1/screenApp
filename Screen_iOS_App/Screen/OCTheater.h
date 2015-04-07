//
//  OCTheater.h
//  Screen
//
//  Created by Mason Wolters on 12/2/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface OCTheater : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *theaterId;
@property (strong, nonatomic) NSDictionary *location;
@property (strong, nonatomic) NSString *phoneNumber;

@property (strong, nonatomic) NSDictionary *address;

- (float)getLatitude;
- (float)getLongitude;
- (float)getDistance;

+ (NSDictionary *)searchMappings;
+ (RKObjectMapping *)searchMapping;

+ (NSDictionary *)nowPlayingMappings;
+ (RKObjectMapping *)nowPlayingMapping;


@end
