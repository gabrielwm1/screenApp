//
//  OCVideo.h
//  Screen
//
//  Created by Mason Wolters on 2/20/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

//  For VOD Availability

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface OCVideo : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *url;

+ (NSDictionary *)mappings;
+ (RKObjectMapping *)mapping;

@end
