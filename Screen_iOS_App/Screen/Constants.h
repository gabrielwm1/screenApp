//
//  Constants.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef NSComparisonResult(^ComparisonBlock)(id obj1, id obj2);

typedef enum {
    sortTypeRelease,
    sortTypeTomatoes,
    sortTypeDemand,
    sortTypeLocation
} SortType;

@interface Constants : NSObject

extern NSString *overrideRowHighlightNotification;

extern int whiteColor;
extern int blueColor;
extern int greenColor;
extern int grayColor;
extern int darkGrayColor;
extern int cellSelectColor;
extern int redColor;



@end
