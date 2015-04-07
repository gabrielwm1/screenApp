//
//  SimilarTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 12/29/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimilarMoviesView;

@interface SimilarTableViewCell : UITableViewCell {
    BOOL didUpdateConstraints;
}

@property (strong, nonatomic) SimilarMoviesView *similarMoviesView;

@end
