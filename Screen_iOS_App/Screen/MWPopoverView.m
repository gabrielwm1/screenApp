//
//  MWPopoverView.m
//  SailingTimer
//
//  Created by Mason Wolters on 7/22/14.
//  Copyright (c) 2014 Mason Wolters. All rights reserved.
//

#import "MWPopoverView.h"


@implementation MWPopoverView

@synthesize view;
@synthesize dimView;
@synthesize displayPoint;
@synthesize popoverPosition;
@synthesize container;
@synthesize targetSize;

@synthesize strokeColor;
@synthesize background;

#pragma mark - Public API

+ (MWPopoverView*)popoverWithSize:(CGSize)size inView:(UIView *)view {
    MWPopoverView *popover = [[MWPopoverView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    popover.view = view;
    popover.targetSize = size;
    
    popover.strokeColor = [UIColor blackColor];
    popover.background = [UIColor whiteColor];
    
    return popover;
}

#pragma mark - API

- (void)showFromPoint:(CGPoint)point {
    self.transform = CGAffineTransformIdentity;
    self.layer.anchorPoint = [self correctAnchorPointForPosition:[self currentPopoverPosition]];

    displayPoint = CGPointMake(point.x - (self.layer.anchorPoint.x*[self correctFrameWidth]), point.y - (self.layer.anchorPoint.y*[self correctFrameHeight]));
    
    [self showDimWithSelector:@selector(tapDim)];
    
    self.frame = [self correctFrame];
    self.container.frame = [self correctContainerFrame];
    self.transform = CGAffineTransformMakeScale(.001, .001);
    [view addSubview:self];
    
    POPSpringAnimation *open = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    open.springBounciness = 10;
    open.springSpeed = 16;
    open.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    
    [self.layer pop_addAnimation:open forKey:@"open"];
    
}

- (void)hideWithDuration:(float)duration animationBlock:(void (^)(void))animations {
    [self hideDim];
    [UIView animateWithDuration:duration animations:animations completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)hide {
    [self tapDim];
}

#pragma mark - Private

- (CGRect)correctContainerFrame {
    float x = 0;
    float y = 0;
    float width = targetSize.width;
    float height = targetSize.height;
    
    switch ([self currentPopoverPosition]) {
        case mwPopoverPositionBottom: x=0; y=20; break;
        case mwPopoverPositionTop: x=0; y=0; break;
        case mwPopoverPositionLeft: x=0; y=0; break;
        case mwPopoverPositionRight: x=20; y=0; break;
        default: break;
    }
    
    return CGRectMake(x, y, width, height);
}

- (float)correctFrameWidth {
    return ([self currentPopoverPosition] == mwPopoverPositionLeft || [self currentPopoverPosition] == mwPopoverPositionRight)?targetSize.width+20:targetSize.width;
}

- (float)correctFrameHeight {
    return ([self currentPopoverPosition] == mwPopoverPositionTop || [self currentPopoverPosition] == mwPopoverPositionBottom)?targetSize.height+20:targetSize.height;
}

- (CGRect)correctFrame {
    float x = displayPoint.x;
    float y = displayPoint.y;
    float width = [self correctFrameWidth];
    float height = [self correctFrameHeight];
    return CGRectMake(x, y, width, height);
}

- (void)showDimWithSelector:(SEL)selector {
    dimView = [[UIView alloc] initWithFrame:view.bounds];
    dimView.backgroundColor = [UIColor blackColor];
    dimView.alpha = 0.0f;
    [view addSubview:dimView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [dimView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:.2 animations:^{
        dimView.alpha = .5f;
    }];
}

- (void)hideDim {
    [UIView animateWithDuration:.2f animations:^{
        dimView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [dimView removeFromSuperview];
    }];
}

- (void)tapDim {
    [self hideDim];
    
    POPSpringAnimation *hide = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    
    hide.springBounciness = 0.0f;
    hide.springSpeed = 25;
    hide.toValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
    
    UIView *temp = self;
    
    hide.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        [temp removeFromSuperview];
    };
    
    [self.layer pop_removeAllAnimations];
    [self.layer pop_addAnimation:hide forKey:@"scale"];
}

#pragma mark - Utilities

- (CGPoint)correctAnchorPointForPosition:(MWPopoverPosition)position {
    if (position == mwPopoverPositionBottom) {
        return CGPointMake(0.5f, 0.0f);
    } else if (position == mwPopoverPositionLeft) {
        return CGPointMake(1.0f, 0.5f);
    } else if (position == mwPopoverPositionRight) {
        return CGPointMake(0.0f, 0.5f);
    } else if (position == mwPopoverPositionTop) {
        return CGPointMake(0.5f, 1.0f);
    } else {
        return CGPointMake(0, 0);
    }
}

- (MWPopoverPosition)currentPopoverPosition {
    if (popoverPosition == mwPopoverPositionAuto) {
        return [self popoverPositionForAuto];
    } else {
        return popoverPosition;
    }
}

- (MWPopoverPosition)popoverPositionForAuto {
    if (displayPoint.x < self.frame.size.width/2 + 10) {
        //too far left
        return mwPopoverPositionRight;
    } else if (displayPoint.x > view.frame.size.width - self.frame.size.width/2 - 10) {
        //too far right
        return mwPopoverPositionLeft;
    } else {
        if (displayPoint.y < view.frame.size.height/2) {
            //top half
            return mwPopoverPositionBottom;
        } else {
            //bottom half
            return mwPopoverPositionTop;
        }
    }
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.popoverPosition = mwPopoverPositionAuto;
        
        self.backgroundColor = [UIColor clearColor];
        
        container = [[UIView alloc] initWithFrame:self.bounds];
        container.layer.masksToBounds = YES;
        container.layer.cornerRadius = 5.0f;
        [self addSubview:container];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5.0f;
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    float width = rect.size.width;
    float height = rect.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, background.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    
    CGRect containerFrame = [self correctContainerFrame];
    UIBezierPath *containerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(containerFrame.origin.x + .5, containerFrame.origin.y+.5, containerFrame.size.width-1, containerFrame.size.height-1) cornerRadius:5.0f];
    
    CGContextBeginPath(context);
    CGContextAddPath(context, containerPath.CGPath);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    CGContextAddPath(context, containerPath.CGPath);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, background.CGColor);
    
    CGPoint point1 = CGPointMake(width/2-15, height-20-.5); //left up on triangle pointing down
    CGPoint point2 = CGPointMake(width/2, height); //middle down on triangle pointing down;
    CGPoint point3 = CGPointMake(width/2+15, height-20-.5); //right up on triangle pointing down;
    
    if ([self currentPopoverPosition] == mwPopoverPositionTop) {
        point1 = CGPointMake(width/2-15, height-20-.5);
        point2 = CGPointMake(width/2, height-.5);
        point3 = CGPointMake(width/2+15, height-20-.5);
    } else if ([self currentPopoverPosition] == mwPopoverPositionBottom) {
        point1 = CGPointMake(width/2-15, 20.5);
        point2 = CGPointMake(width/2, .5);
        point3 = CGPointMake(width/2+15, 20.5);
    } else if ([self currentPopoverPosition] == mwPopoverPositionLeft) {
        point1 = CGPointMake(width-20 - .5, height/2-15);
        point2 = CGPointMake(width-.5, height/2);
        point3 = CGPointMake(width-20 - .5, height/2+15);
    } else if ([self currentPopoverPosition] == mwPopoverPositionRight) {
        point1 = CGPointMake(20.5, height/2-15);
        point2 = CGPointMake(.5, height/2);
        point3 = CGPointMake(20.5, height/2+15);
    }
    
    //cover outline from containerView
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point3.x, point3.y);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    
    //fill triangle
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point3.x, point3.y);
    CGContextAddLineToPoint(context, point2.x, point2.y);
    CGContextAddLineToPoint(context, point1.x, point1.y);
    CGContextFillPath(context);
    
    //stroke triangle
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point2.x, point2.y);
    CGContextAddLineToPoint(context, point3.x, point3.y);
    CGContextStrokePath(context);
    
}


@end
