//
//  ProfileNavButton.m
//  Screen
//
//  Created by Mason Wolters on 11/21/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "ProfileNavButton.h"

@implementation ProfileNavButton

@synthesize profileView;
@synthesize nameLabel;
@synthesize delegate;

- (void)tap {
    [delegate didTapProfileNavButton];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
        
        profileView = [[ProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
        
//        if ([[PFUser currentUser] objectForKey:@"fbId"] && ![[[PFUser currentUser] objectForKey:@"fbId"] isEqualToString:@""]) {
//            profileView.facebookId = [[PFUser currentUser] objectForKey:@"fbId"];
//        } else {
//            profileView.imageURL = nil;
//        }
        profileView.user = [PFUser currentUser];
        
        [self addSubview:profileView];
        
        float labelX = profileView.frame.origin.x + profileView.frame.size.width + 5;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, frame.size.width - labelX, frame.size.height)];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.text = @"Me";
        [self addSubview:nameLabel];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
