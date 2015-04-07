//
//  PFCrew.h
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFCrew : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *creditId;
@property (strong, nonatomic) NSString *department;
@property (strong, nonatomic) NSString *crewId;
@property (strong, nonatomic) NSString *job;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *profilePath;

+ (NSString *)parseClassName;
+ (void)load;

@end
