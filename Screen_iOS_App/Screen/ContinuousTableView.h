//
//  ContinuousTableView.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RTSpinKitView.h>

typedef void(^SuccessBlock)(void);

@protocol ContinuousTableViewDelegate <NSObject>

- (void)loadPage:(int)page done:(SuccessBlock)done error:(SuccessBlock)error;

@end

@interface ContinuousTableView : UITableView {
    BOOL hasInitialized;
}

@property (strong, nonatomic) RTSpinKitView *spinner;
@property (weak, nonatomic) NSObject<ContinuousTableViewDelegate> *continuousDelegate;
@property (nonatomic) BOOL loading;
@property (nonatomic) int currentPage;
@property (nonatomic) int totalPages;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end
