//
//  OCOrganizedShowtime.m
//  Screen
//
//  Created by Mason Wolters on 12/3/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "OCOrganizedShowtime.h"

@implementation Showtime

@end

@implementation OCOrganizedShowtime

- (NSArray *)timesDaysAfterToday:(int)days {
    if ([self.days objectForKey:[NSNumber numberWithInt:days]]) {
        return [self.days objectForKey:[NSNumber numberWithInt:days]];
    }
    return [NSArray array];
}

@end
