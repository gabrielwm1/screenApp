//
//  LoadingTableViewCell.m
//  Screen
//
//  Created by Mason Wolters on 12/18/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "LoadingTableViewCell.h"
#import "UIImage+Color.h"
#import "Constants.h"

@implementation RetryButton

@synthesize retryImage;
@synthesize retryLabel;
@synthesize containerView;

- (void)addTarget:(id)target selector:(SEL)selector {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        retryImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        retryImage.image = [UIImage imageNamed:@"retry"];
        [self addSubview:retryImage];
    }
    
    return self;
}

@end

@implementation ErrorImage

@synthesize whiteImage;
@synthesize redImage;

- (void)animateToRedImageWithDuration:(float)duration {
    [UIView animateWithDuration:duration animations:^{
        whiteImage.alpha = 0.0f;
    }];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        whiteImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        redImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        whiteImage.image = [UIImage imageNamed:@"add"];
        redImage.image = [[UIImage imageNamed:@"add"] imageWithColor:UIColorFromRGB(redColor)];
        
        whiteImage.transform = CGAffineTransformMakeRotation(.25 * M_PI);
        redImage.transform = CGAffineTransformMakeRotation(.25 * M_PI);
        
        whiteImage.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        redImage.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        [self addSubview:redImage];
        [self addSubview:whiteImage];
    }
    
    return self;
}

@end

@implementation LoadingTableViewCell

@synthesize activityIndicator;
@synthesize errorImage = _errorImage;
@synthesize retryButton = _retryButton;
@synthesize retryHandler;

- (void)start {
    activityIndicator.transform = CGAffineTransformIdentity;
    activityIndicator.alpha = 1.0f;
    [activityIndicator startAnimating];
    
    _retryButton.alpha = 0.0f;
    _errorImage.alpha = 0.0f;
}

- (void)goToErrorRetry {
    self.errorImage.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
    self.errorImage.transform = CGAffineTransformMakeTranslation(0, -self.contentView.frame.size.height);
    self.errorImage.alpha = 1.0f;
    [self.contentView addSubview:self.errorImage];
    
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.5f initialSpringVelocity:.6f options:0 animations:^{
        self.contentView.backgroundColor = UIColorFromRGB(redColor);
        self.errorImage.transform = CGAffineTransformIdentity;
        activityIndicator.transform = CGAffineTransformMakeTranslation(0, self.contentView.frame.size.height);
        activityIndicator.alpha = 0.0f;
    }completion:^(BOOL complete) {
        [self performSelector:@selector(goToClearBackground) withObject:nil afterDelay:.7f];
    }];
}

- (void)goToClearBackground {
    self.retryButton.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
    self.retryButton.transform = CGAffineTransformMakeTranslation(0, -self.contentView.frame.size.height);
    self.retryButton.alpha = 1.0f;
    
    [UIView animateWithDuration:.3f animations:^{
        self.contentView.backgroundColor = [UIColor clearColor];
    }];
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.5f initialSpringVelocity:.6f options:0 animations:^{
        self.errorImage.transform = CGAffineTransformMakeTranslation(0, self.contentView.frame.size.height);
        self.errorImage.alpha = 0.0f;
        self.retryButton.transform = CGAffineTransformIdentity;
    }completion:nil];
}

- (void)goToLoading {
    self.activityIndicator.alpha = 1.0f;
    self.activityIndicator.transform = CGAffineTransformMakeTranslation(0, -self.contentView.frame.size.height);
    
    [UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.5f initialSpringVelocity:.6f options:0 animations:^{
        self.retryButton.transform = CGAffineTransformMakeTranslation(0, self.contentView.frame.size.height);
        self.retryButton.alpha = 0.0f;
        self.activityIndicator.transform = CGAffineTransformIdentity;
    }completion:nil];
}

- (void)tapRetry {
    [self goToLoading];
    if (retryHandler) {
        retryHandler();
    }
}

- (ErrorImage *)errorImage {
    if (!_errorImage) {
        _errorImage = [[ErrorImage alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    }
    
    return _errorImage;
}

- (RetryButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [[RetryButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_retryButton addTarget:self selector:@selector(tapRetry)];
        [self.contentView addSubview:_retryButton];
    }
    
    return _retryButton;
}

- (void)goToRetryUnanimated {
    self.retryButton.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
    self.retryButton.alpha = 1.0f;
    self.activityIndicator.alpha = 0.0f;
    _errorImage.alpha = 0.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    activityIndicator.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.clipsToBounds = YES;
        self.contentView.layer.masksToBounds = YES;
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator startAnimating];
        [self.contentView addSubview:activityIndicator];
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
