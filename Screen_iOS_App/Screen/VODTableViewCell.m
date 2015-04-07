//
//  VODTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 2/20/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "VODTableViewCell.h"
#import "VODView.h"

@implementation VODTableViewCell

@synthesize collectionView;
@synthesize vodAvailabilities = _vodAvailabilities;
@synthesize delegate;
@synthesize screenWidth;

- (void)setVodAvailabilities:(NSArray *)vodAvailabilities {
    _vodAvailabilities = vodAvailabilities;
    
    [self.collectionView reloadData];
}

- (void)updateConstraints {
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    
    [super updateConstraints];
    
    float cellHeight = 34.0f;
    if (screenWidth > 320) {
        [layout setItemSize:CGSizeMake(110, 40)];
        cellHeight = 40.0f;
    }
    
    int rowsCount = (int)ceilf((float)_vodAvailabilities.count / 3.0f);
    float height = rowsCount * cellHeight + (rowsCount-1) * 8.0f + 8.0f;
    NSLog(@"Vod height: %f", height);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[collectionView(%f)]|", height] options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    
    [super updateConstraints];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _vodAvailabilities.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (![cell.contentView viewWithTag:101]) {
        VODView *vod = [[VODView alloc] init];
        [vod setTranslatesAutoresizingMaskIntoConstraints:NO];
        [vod setTag:101];
        [cell.contentView addSubview:vod];
        
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vod]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vod)]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[vod]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vod)]];
    }
    
    [(VODView *)[cell.contentView viewWithTag:101] setVodAvailability:_vodAvailabilities[indexPath.item]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VODAvailability *vod = _vodAvailabilities[indexPath.item];
    if ([delegate respondsToSelector:@selector(tappedVODLink:)]) {
        [delegate tappedVODLink:vod.link];
    }
}

#pragma mark - UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 5.0f;
        layout.minimumLineSpacing = 8.0f;
        [layout setItemSize:CGSizeMake(93.5, 34)];
        
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.contentInset = UIEdgeInsetsMake(0, 13, 0, 13);
        [collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.scrollEnabled = NO;
        [self.contentView addSubview:collectionView];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
