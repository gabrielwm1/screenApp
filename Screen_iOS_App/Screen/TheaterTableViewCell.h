//
//  TheaterTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 12/29/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCTheater;
@class OCMovie;

#import "AutoLayoutCollectionView.h"

@protocol TheaterCellDelegate <NSObject>

- (void)selectedTheater:(OCTheater *)theater;
- (void)selectedTheater:(OCTheater *)theater movie:(OCMovie *)movie;

@end

@interface TheaterTableViewCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, AutoLayoutCollectionViewDelegate> {
    NSArray *showtimes;
    UIView *selectionBackground;
    BOOL didUpdateConstraints;
    UIView *test;
    NSLayoutConstraint *collectionViewHeight;
    UITapGestureRecognizer *tap;
}

@property (strong, nonatomic) OCTheater *theater;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) NSObject<TheaterCellDelegate> *delegate;
@property (strong, nonatomic) NSArray *showtimes;

@end
