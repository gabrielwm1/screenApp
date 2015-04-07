//
//  OCOrganizedShowtime.h
//  Screen
//
//  Created by Mason Wolters on 12/3/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCTheater.h"
#import "OCMovie.h"

@interface Showtime : NSObject

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *attribute; //3d, imax, etc
@property (strong, nonatomic) NSString *timeString;

@end

@interface OCOrganizedShowtime : NSObject

@property (strong, nonatomic) OCTheater *theater;
@property (strong, nonatomic) OCMovie *movie;
@property (strong, nonatomic) NSArray *timesToday;
@property (strong, nonatomic) NSArray *timesTomorrow;
@property (strong, nonatomic) NSArray *timesDayAfterTomorrow;

@property (strong, nonatomic) NSMutableDictionary *days;

- (NSArray *)timesDaysAfterToday:(int)days;

@end
