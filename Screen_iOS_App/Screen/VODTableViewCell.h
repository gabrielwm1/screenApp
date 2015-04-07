//
//  VODTableViewCell.h
//  Screen
//
//  Created by Mason Wolters on 2/20/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VODTableViewCellDelegate <NSObject>

- (void)tappedVODLink:(NSString *)link;

@end

@interface VODTableViewCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate> {
    BOOL didUpdateConstraints;
    UICollectionViewFlowLayout *layout;
}

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *vodAvailabilities;
@property (weak, nonatomic) NSObject<VODTableViewCellDelegate> *delegate;
@property (nonatomic) float screenWidth;

@end
