//
//  AutoLayoutCollectionView.m
//  Screen
//
//  Created by Mason Wolters on 12/29/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "AutoLayoutCollectionView.h"

@implementation AutoLayoutCollectionView

@synthesize subDelegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (!touching) {
//        [delegate touchesBegan];
//    }
//    touching = YES;
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (touching) {
//        [delegate touchesEnded];
//    }
//    
//    touching = NO;
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (touching) {
//        [delegate touchesEnded];
//    }
//    
//    touching = NO;
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize]))
    {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = self.collectionViewLayout.collectionViewContentSize;
    
    return intrinsicContentSize;
//    return CGSizeMake(320, 50);
}

@end
