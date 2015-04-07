//
//  FriendMovieTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 12/3/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "FriendMovieTableViewCell.h"
#import <EDStarRating/EDStarRating.h>
#import "Constants.h"
#import "UIImage+Color.h"
#import <PureLayout/PureLayout.h>
#import "ProfilePictureView.h"

@implementation FriendMovieTableViewCell

@synthesize user = _user;
@synthesize separator;
@synthesize starRating;
@synthesize titleLabel;
@synthesize statusLabel;
@synthesize profilePictureView;
@synthesize inviteButton;
@synthesize inviteLabel;
@synthesize watchlistIcon;
@synthesize delegate;
@synthesize activityIndicator = _activityIndicator;

- (void)setUser:(PFUser *)user {
    _user = user;
    
    self.profilePictureView.user = user;
    
    self.titleLabel.text = user[@"name"];
}

- (void)tapInvite {
    if (delegate && [delegate respondsToSelector:@selector(tappedInviteForUser:stopActivityIndicator:)]) {
        inviteLabel.alpha = 0.0f;
        [self.activityIndicator startAnimating];
        BlankBlock block = ^{
            inviteLabel.alpha = 1.0f;
            [_activityIndicator removeFromSuperview];
        };
        [delegate tappedInviteForUser:self.user stopActivityIndicator:block];
    }
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initForAutoLayout];
    }
    
    [inviteButton addSubview:_activityIndicator];
    
    [inviteButton addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:inviteButton attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
    [inviteButton addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:inviteButton attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
    
    return _activityIndicator;
}

- (void)updateConstraints {
    if (!didUpdateConstraints) {
        didUpdateConstraints = YES;
        
        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[separator]-13-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separator(==0.5)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];
        
        if (identifier) {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[profilePictureView(30)]-12-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(profilePictureView)]];
            [statusLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        }
        
        if ([identifier isEqualToString:@"manualFriendRatingCell"]) {

            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-13-[profilePictureView(30)]-8-[titleLabel]->=8-[starRating(80)]-14-|" options:NSLayoutFormatAlignAllCenterY metrics:nil
                                                                                       views:NSDictionaryOfVariableBindings(profilePictureView, titleLabel, starRating)]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[starRating(27)]-(>=0)-|" options:0 metrics:nil
                                                                                       views:NSDictionaryOfVariableBindings(starRating)]];
            
        } else if ([identifier isEqualToString:@"manualFriendCell"]) {

            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-13-[profilePictureView]-8-[titleLabel]->=8-[statusLabel]-14-|" options:NSLayoutFormatAlignAllCenterY metrics:nil
                                                                                       views:NSDictionaryOfVariableBindings(profilePictureView, titleLabel, statusLabel)]];
            
        } else if ([identifier isEqualToString:@"manualFriendInviteCell"]) {
            
            [inviteButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[inviteLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(watchlistIcon, inviteLabel)]];
            
            [inviteButton addConstraint:[NSLayoutConstraint constraintWithItem:inviteLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:inviteButton attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
            
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:watchlistIcon attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:16]];
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-13-[profilePictureView]-8-[titleLabel]->=8-[inviteButton]-4-[watchlistIcon(16)]-14-|" options:NSLayoutFormatAlignAllCenterY metrics:nil
                                                                                       views:NSDictionaryOfVariableBindings(profilePictureView, titleLabel, watchlistIcon, inviteButton)]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[inviteButton(30)]-(>=0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inviteButton)]];
        }
    }
    
    [super updateConstraints];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        identifier = reuseIdentifier;
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        separator = [[UIView alloc] init];
        separator.backgroundColor = [UIColor whiteColor];
        separator.alpha = .5f;
        [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:separator];
        
        profilePictureView = [[ProfilePictureView alloc] init];
        [profilePictureView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:profilePictureView];
        
        titleLabel = [[UILabel alloc] initForAutoLayout];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [self.contentView addSubview:titleLabel];
        
        if ([reuseIdentifier isEqualToString:@"manualFriendRatingCell"]) {
            
            starRating = [[EDStarRating alloc] init];
            [starRating setTranslatesAutoresizingMaskIntoConstraints:NO];
            starRating.backgroundColor = [UIColor clearColor];
            starRating.starImage = [[UIImage imageNamed:@"star-template.png"] imageWithColor:UIColorFromRGB(0xffa200)];
            starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithColor:UIColorFromRGB(0xffa200)];
            starRating.maxRating = 5.0;
            starRating.horizontalMargin = 0;
            starRating.editable=NO;
            starRating.rating= 0.0;
            starRating.displayMode = EDStarRatingDisplayAccurate;
            [self.contentView addSubview:starRating];

        } else if ([reuseIdentifier isEqualToString:@"manualFriendCell"]) {
            
            statusLabel = [[UILabel alloc] initForAutoLayout];
            statusLabel.textColor = [UIColor whiteColor];
            statusLabel.font = [UIFont systemFontOfSize:12.0f];
            [self.contentView addSubview:statusLabel];
            
        } else if ([reuseIdentifier isEqualToString:@"manualFriendInviteCell"]) {
            
            inviteButton = [[UIView alloc] initForAutoLayout];
            inviteButton.backgroundColor = UIColorFromRGB(grayColor);
            inviteButton.layer.cornerRadius = 5.0f;
            [self.contentView addSubview:inviteButton];
            
            inviteLabel = [[UILabel alloc] initForAutoLayout];
            inviteLabel.textColor = [UIColor whiteColor];
            inviteLabel.text = @"Invite";
            inviteLabel.font = [UIFont systemFontOfSize:14.0f];
            [inviteButton addSubview:inviteLabel];
            
            watchlistIcon = [[UIImageView alloc] initForAutoLayout];
            watchlistIcon.image = [UIImage imageNamed:@"watchlist"];
            [self.contentView addSubview:watchlistIcon];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInvite)];
            [inviteButton addGestureRecognizer:tap];
            
        }
        
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    separator = [[UIView alloc] init];
    separator.backgroundColor = [UIColor whiteColor];
    separator.alpha = .5f;
    [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:separator];
    
    // align separator from the left and right
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[separator]-13-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];
    
    // align separator from the bottom
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separator(==0.5)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];
    
    if (starRating) {
        starRating.backgroundColor = [UIColor clearColor];
        starRating.starImage = [[UIImage imageNamed:@"star-template.png"] imageWithColor:UIColorFromRGB(0xffa200)];
        starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithColor:UIColorFromRGB(0xffa200)];
        starRating.maxRating = 5.0;
        starRating.horizontalMargin = 0;
        starRating.editable=NO;
        starRating.rating= 0.0;
        starRating.displayMode = EDStarRatingDisplayAccurate;
    }
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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //    [super setHighlighted:highlighted animated:animated];
    
    [[self selectionBackground] setAlpha:(highlighted)?1.0f:0.0f];
    //    self.contentView.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    //    self.backgroundColor = (highlighted)?UIColorFromRGB(cellSelectColor):[UIColor clearColor];
    
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
