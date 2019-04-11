//
//  LoadingView.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()
@property (nonatomic, strong) UIImageView *rotateView;
@end

@implementation LoadingView

+ (instancetype)shared {
    static LoadingView *sharedView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
        [sharedView setup];
    });
    return sharedView;
}

- (void)setup {
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
    bg.image = [UIImage imageNamed:@"default_page_icon_load"];
    [self addSubview:bg];
    
    self.rotateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 33, 66)];
    self.rotateView.image = [UIImage imageNamed:@"default_page_icon_loading"];
    [bg addSubview:self.rotateView];
    [self setAnchorPoint:CGPointMake(1, 0.5) forView:self.rotateView];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGRect oldFrame = view.frame;
    view.layer.anchorPoint = anchorPoint;
    view.frame = oldFrame;
}

+ (CABasicAnimation *)rotateAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    animation.duration = 1;
    animation.repeatCount = HUGE_VALF;
    return animation;
}

+ (void)showOnView:(UIView *)view {
    LoadingView *tmp = [LoadingView shared];
    tmp.center = view.center;
    [view addSubview:tmp];
    [view bringSubviewToFront:tmp];
    [tmp.rotateView.layer addAnimation:[LoadingView rotateAnimation] forKey:@"rotateAnimation"];
}

+ (void)hide {
    LoadingView *tmp = [LoadingView shared];
    [tmp.rotateView.layer removeAllAnimations];
    [tmp removeFromSuperview];
}

@end
