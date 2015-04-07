//
//  GPPhoto.h
//  Screen
//
//  Created by Mason Wolters on 12/4/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface GPPhoto : NSObject

@property (strong, nonatomic) NSString *photoReference;
@property (strong, nonatomic) NSString *width;
@property (strong, nonatomic) NSString *height;

+ (NSDictionary *)mappings;
+ (RKObjectMapping *)mapping;

@end
