//
//  SimilarMoviesView.m
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "SimilarMoviesView.h"

@implementation SimilarMoviesView

@synthesize movies = _movies;
@synthesize collectionView;
@synthesize delegate;

- (void)setMovies:(NSArray *)movies {
    _movies = movies;
    NSMutableArray *withImages = [NSMutableArray array];
    for (TMDBMovie *movie in movies) {
        if (movie.posterPath && ![movie.posterPath isEqualToString:@""]) {
            [withImages addObject:movie];
        }
    }
    moviesWithImages = [NSArray arrayWithArray:withImages];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return moviesWithImages.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (![cell.contentView viewWithTag:101]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        imageView.tag = 101;
        [cell.contentView addSubview:imageView];
    }
    
    [(UIImageView *)[cell.contentView viewWithTag:101] sd_setImageWithURL:[[TMDBHelper sharedInstance] urlForImageResource:[moviesWithImages[indexPath.item] posterPath] size:@"w154"] placeholderImage:[UIImage imageNamed:@"blankPoster"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [delegate tappedMovie:moviesWithImages[indexPath.item]];
}

#pragma mark - UIView

- (void)updateConstraints {
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
    
    [super updateConstraints];
}

- (id)init {
    self = [super init];
    
    if (self) {
        
        layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        float height = 120;
        float width = height * .66666667;
        layout.itemSize = CGSizeMake(width, height);
        
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //        collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 120) collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.alwaysBounceHorizontal = YES;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        self.layer.masksToBounds = NO;
        [self addSubview:collectionView];
        
    }
    
    return self;
}

- (void)awakeFromNib {
    if (!collectionView) {
        
        layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        float height = 120;
        float width = height * .66666667;
        layout.itemSize = CGSizeMake(width, height);
        
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
//        collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 120) collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.alwaysBounceHorizontal = YES;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        self.layer.masksToBounds = NO;
        [self addSubview:collectionView];
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(200, 120);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    collectionView.frame = CGRectMake(0, 0, self.bounds.size.width, 120);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
