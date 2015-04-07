//
//  TheaterTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 12/29/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TheaterTableViewCell.h"
#import "OnConnectHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"

const float sideInset = 13.0f;

@implementation TheaterTableViewCell

@synthesize theater = _theater;
@synthesize titleLabel;
@synthesize distanceLabel;
@synthesize collectionView;
@synthesize delegate;
@synthesize showtimes;

#pragma mark - Private

- (void)setTheater:(OCTheater *)theater {
    _theater = theater;
    
    [self.collectionView setContentOffset:CGPointMake(-sideInset, 0) animated:NO];
    
    [self refresh];
}

- (void)refresh {
    titleLabel.text = _theater.name;
    
    if ([_theater.location objectForKey:@"distance"]) {
        distanceLabel.text = [NSString stringWithFormat:@"%.01f mi", [[_theater.location objectForKey:@"distance"] floatValue]];
    } else {
        distanceLabel.text = @"";
    }

    [collectionView reloadData];
}

- (void)tapCollectionView {
    NSLog(@"tap collection view");
    [delegate selectedTheater:_theater];
}

- (void)tapPoster:(UITapGestureRecognizer *)tapp {
    NSLog(@"tap poster");
    if ([delegate respondsToSelector:@selector(selectedTheater:movie:)]) {
        OCOrganizedShowtime *showtime = showtimes[tapp.view.superview.tag];
        [delegate selectedTheater:_theater movie:showtime.movie];
    }
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return showtimes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (![cell.contentView viewWithTag:101]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 60)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = 101;
        imageView.userInteractionEnabled = YES;
        [cell.contentView addSubview:imageView];
        
        UITapGestureRecognizer *tapPoster = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPoster:)];
        [imageView addGestureRecognizer:tapPoster];
    }
    
    cell.contentView.tag = indexPath.item;
    
    OCOrganizedShowtime *showtime = showtimes[indexPath.row];
    [(UIImageView*)[cell.contentView viewWithTag:101]
        sd_setImageWithURL:[[OnConnectHelper sharedInstance] urlForImageResource:showtime.movie.posterPath size:@"h=120"]
            placeholderImage:[UIImage imageNamed:@"blankPoster"]];
    
    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"selected collection view");
//    if ([delegate respondsToSelector:@selector(selectedTheater:movie:)]) {
//        OCOrganizedShowtime *showtime = showtimes[indexPath.item];
//        [delegate selectedTheater:_theater movie:showtime.movie];
//    }
//}

- (void)touchesBegan {
    [self setHighlighted:YES];
}

- (void)touchesEnded {
    [self setHighlighted:NO];
}

#pragma mark - UITableViewCell

- (void)updateConstraints {
    if (!didUpdateConstraints) {
        
        NSString *horiz1 = [NSString stringWithFormat:@"H:|-%f-[titleLabel]-(>=8)-[distanceLabel]-%f-|", sideInset, sideInset];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horiz1 options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(titleLabel, distanceLabel)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[titleLabel]-8-[collectionView(60)]-13-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel, collectionView)]];
        
        [distanceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        didUpdateConstraints = YES;
    }
    
    [super updateConstraints];
}

- (UIView *)selectionBackground {
    if (!selectionBackground) {
        selectionBackground = [[UIView alloc] initWithFrame:self.contentView.bounds];
        selectionBackground.backgroundColor = UIColorFromRGB(cellSelectColor);
        selectionBackground.alpha = 0.0f;
        
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        
        CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
        CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        
        maskLayer.colors = [NSArray arrayWithObjects:(__bridge id)outerColor,
                            (__bridge id)innerColor, (__bridge id)innerColor, (__bridge id)outerColor, nil];
        maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.1],
                               [NSNumber numberWithFloat:0.9],
                               [NSNumber numberWithFloat:1.0], nil];
        
        maskLayer.bounds = CGRectMake(0, 0,
                                      self.contentView.frame.size.width,
                                      self.contentView.frame.size.height);
        maskLayer.anchorPoint = CGPointZero;
        
        selectionBackground.layer.mask = maskLayer;
        
        
        [self.contentView insertSubview:selectionBackground atIndex:0];
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    selectionBackground.frame = self.contentView.bounds;
    selectionBackground.layer.mask.bounds = self.contentView.bounds;
    [CATransaction commit];
    
    return selectionBackground;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [self.contentView addSubview:titleLabel];
        
        distanceLabel = [[UILabel alloc] init];
        [distanceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        distanceLabel.textColor = [UIColor whiteColor];
        distanceLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:distanceLabel];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(40, 60);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.contentInset = UIEdgeInsetsMake(0, sideInset, 0, sideInset);
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.delegate = self;
        collectionView.alwaysBounceHorizontal = YES;
        [self.contentView addSubview:collectionView];
        
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCollectionView)];
        tap.delegate = self;
        [collectionView addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //    [super setHighlighted:highlighted animated:animated];
    
    self.contentView.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    self.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (animated) {
        [UIView animateWithDuration:.2f animations:^{
            self.contentView.backgroundColor = (selected)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
        }];
    } else {
        self.contentView.backgroundColor = (selected)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    }
}

@end
