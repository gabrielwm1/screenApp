//
//  PFCast.h
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFCast : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *castId;
@property (strong, nonatomic) NSString *character;
@property (strong, nonatomic) NSString *creditId;
@property (strong, nonatomic) NSString *tmdbCastId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *order;
@property (strong, nonatomic) NSString *profilePath;

+ (NSString *)parseClassName;
+ (void)load;

@end
