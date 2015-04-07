//
//  AutoLayoutCollectionView.h
//  Screen
//
//  Created by Mason Wolters on 12/29/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AutoLayoutCollectionViewDelegate <NSObject>

- (void)touchesBegan;
- (void)touchesEnded;

@end

@interface AutoLayoutCollectionView : UICollectionView {
    BOOL touching;
}

@property (weak, nonatomic) NSObject<AutoLayoutCollectionViewDelegate> *subDelegate;

@end
