//
//  PFMovieLocation.h
//  Screen
//
//  Created by Mason Wolters on 11/11/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Parse/Parse.h>

@class PFMovie;

@interface PFMovieLocation : PFObject <PFSubclassing>

@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) PFMovie *movie;
@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) NSString *movieId;

+ (NSString *)parseClassName;
+ (void)load;

@end
