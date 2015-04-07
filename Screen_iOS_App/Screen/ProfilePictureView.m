//
//  ProfilePictureView.m
//  Screen
//
//  Created by Mason Wolters on 11/17/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "ProfilePictureView.h"
#import <Parse/PFUser.h>
#import <Parse/PFFile.h>

@implementation ProfilePictureView

@synthesize facebookId = _facebookId;
@synthesize imageURL = _imageURL;
@synthesize image = _image;
@synthesize user = _user;
@synthesize pictureSize;

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = self.bounds.size.height/2;
    self.layer.masksToBounds = YES;
    
    if (fbPicView) {
        fbPicView.frame = self.bounds;
    }
    
    if (imageView) {
        imageView.frame = self.bounds;
    }
}

- (void)setUser:(PFUser *)user {
    _user = user;
    
    if (pictureSize != fullSize && user[@"pictureThumbnail"]) {
        self.imageURL = [NSURL URLWithString:[(PFFile *)user[@"pictureThumbnail"] url]];
    } else if (pictureSize == fullSize && user[@"picture"]) {
        self.imageURL = [NSURL URLWithString:[(PFFile *)user[@"picture"] url]];
    } else if (user[@"fbId"]) {
        self.facebookId = user[@"fbId"];
    } else if (user[@"twitterImageUrl"]) {
        self.imageURL = [NSURL URLWithString:[self twitterImageFullSize:pictureSize == fullSize]];
    } else {
        self.imageURL = nil;
    }
}

- (NSString *)twitterImageFullSize:(BOOL)fullSize {
    NSString *url = [[PFUser currentUser] objectForKey:@"twitterImageUrl"];
    NSString *extension = [url pathExtension];
    NSString *withoutSize = [url substringToIndex:[url rangeOfString:@"_" options:NSBackwardsSearch].location];
    
    NSString *newUrl = [NSString stringWithFormat:@"%@%@.%@", withoutSize, (fullSize)?@"":@"_bigger",extension];
    NSLog(@"new url: %@", newUrl);
    return newUrl;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
    }
    
    imageView.alpha = 1.0f;
    fbPicView.alpha = 0.0f;
    
    imageView.image = image;
}

- (void)setFacebookId:(NSString *)facebookId {
    _facebookId = facebookId;
    
    imageView.alpha = 0.0f;
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [UIImage imageNamed:@"blankUser"];
        [self addSubview:imageView];
    }
    if (!fbPicView) {
        fbPicView = [[FBProfilePictureView alloc] initWithFrame:self.bounds];
        fbPicView.pictureCropping = FBProfilePictureCroppingSquare;
        [self addSubview:fbPicView];
    }
    
    fbPicView.alpha = 1.0f;
    
    fbPicView.profileID = facebookId;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(30, 30);
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    fbPicView.alpha = 0.0f;
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
    }
    
    imageView.alpha = 1.0f;
    
    if (imageURL == nil) {
        imageView.image = [UIImage imageNamed:(self.pictureSize == fullSize)?@"blankUser":@"blankUserSmall"];
    } else {
        [imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"blankUser"]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
