//
//  NSClippy.m
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import <ImageIO/ImageIO.h>

#import "NSClippy.h"
#import "WZAnimation.h"
#import "WZFrame.h"

@interface NSClippy () <WZAnimationDelegate>
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic) CGSize frameSize;
@property (nonatomic, strong) UIImageView *clippy;
@property (nonatomic, strong) WZAnimation *currentAnimation;
@end

@implementation NSClippy

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    
    if (self) {
        _attributes = attributes;
        _frameSize = CGSizeMake([attributes[@"framesize"][0] integerValue], [attributes[@"framesize"][1] integerValue]);
        self.frame = CGRectMake(0, 0, _frameSize.width, _frameSize.height);
        self.clipsToBounds = YES;
        
        _clippy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Clippy.png"]];
        _clippy.contentMode = UIViewContentModeScaleAspectFill;
        _clippy.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:_clippy];
    }
    
    return self;
}

- (void)showAnimation:(NSString *)animationName {
    if (!_currentAnimation) {
        NSDictionary *animationAttributes = _attributes[@"animations"][animationName];
        CGSize imageSize = CGSizeMake(_clippy.image.size.width, _clippy.image.size.height);
        
        WZAnimation *animation = [[WZAnimation alloc] initWithAttributes:animationAttributes];
        animation.delegate = self;
        animation.frameSize = _frameSize;
        animation.imageSize = imageSize;
        animation.imageView = _clippy;
        _currentAnimation = animation;
        
        [animation play];
    }
}

- (void)exitAnimation {
    [_currentAnimation exit];
}

#pragma mark - WZAnimationDelegate

- (void)animationDidFinish:(NSString *)animationName withState:(WZAnimationState)animationState {
    if (animationState == WZAnimationStateExited) {
        _currentAnimation = nil;
    }
}

#pragma mark - UIView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 0.5;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.superview];
    self.center = loc;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 1.0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 1.0;
}


@end