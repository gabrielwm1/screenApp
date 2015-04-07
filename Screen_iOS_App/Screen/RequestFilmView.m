//
//  RequestFilmView.m
//  Screen
//
//  Created by Mason Wolters on 11/14/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "RequestFilmView.h"

@implementation RequestFilmView

@synthesize requestButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        float width = 200;
        float height = 40;
        requestButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2 - width/2, frame.size.height - height, width, height)];
        [requestButton setTitle:@"Request a Film"  forState:UIControlStateNormal];
        [requestButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.5f] forState:UIControlStateHighlighted];
        requestButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:requestButton];
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
