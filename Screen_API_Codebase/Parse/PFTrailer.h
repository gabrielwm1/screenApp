//
//  PFTrailer.h
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFTrailer : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString *type;

+ (NSString *)parseClassName;
+ (void)load;

@end
