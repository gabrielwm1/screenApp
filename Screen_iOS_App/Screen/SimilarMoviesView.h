//
//  SimilarMoviesView.h
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMDBHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@protocol SimilarMoviesViewDelegate <NSObject>

- (void)tappedMovie:(TMDBMovie*)movie;

@end

@interface SimilarMoviesView : UIView <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSArray *moviesWithImages;
    UICollectionViewFlowLayout *layout;
}

@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) NSObject<SimilarMoviesViewDelegate> *delegate;

@end
