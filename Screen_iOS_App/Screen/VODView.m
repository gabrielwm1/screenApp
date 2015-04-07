//
//  VODView.m
//  Screen
//
//  Created by Mason Wolters on 2/20/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "VODView.h"

@implementation VODView

@synthesize vodAvailability = _vodAvailability;
@synthesize imageView;

- (void)setVodAvailability:(VODAvailability *)vodAvailability {
    _vodAvailability = vodAvailability;
    
    imageView.image = [UIImage imageNamed:[self imageNameForVOD:vodAvailability.service]];
}

- (NSString *)imageNameForVOD:(VOD)vod {
    switch (vod) {
        case vodAmazon: return @"vodAmazon"; break;
        case vodCinemaNow: return @"vodCinemaNow"; break;
        case vodFandor: return @"vodFandor"; break;
        case vodHulu: return @"vodHulu"; break;
        case vodItunes: return @"vodItunes"; break;
        case vodNetflix: return @"vodNetflix"; break;
        case vodVudu: return @"vodVudu"; break;
        case vodYoutube: return @"vodYoutube"; break;
        case vodXfinity: return @"vodXfinity"; break;
        default: return nil; break;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        
        imageView = [[UIImageView alloc] init];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:imageView];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    }
    
    return self;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        
        imageView = [[UIImageView alloc] init];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:imageView];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
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
