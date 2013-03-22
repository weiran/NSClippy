//
//  NSClippy.m
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import "Base64.h"

#import "NSClippy.h"
#import "WZAnimation.h"
#import "WZFrame.h"

@interface NSClippy () <WZAnimationDelegate>
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic) CGSize frameSize;
@property (nonatomic, strong) UIImageView *clippy;
@property (nonatomic, strong) WZAnimation *currentAnimation;
@property (nonatomic, strong) NSDictionary *sounds;
@end

@implementation NSClippy

- (id)initWithAgent:(NSString *)agent {
    self = [super init];
    
    if (self) {
        // get paths
        NSString *pathToAnimations = [NSString stringWithFormat:@"%@-animations.json", agent];
        NSString *pathToImage = [NSString stringWithFormat:@"%@-image.png", agent];
        NSString *pathToSounds = [NSString stringWithFormat:@"%@-sounds.json", agent];
        
        // set attributes
        _attributes = [self attributesForJSON:pathToAnimations];
        _frameSize = CGSizeMake([_attributes[@"framesize"][0] integerValue], [_attributes[@"framesize"][1] integerValue]);
        self.frame = CGRectMake(0, 0, _frameSize.width, _frameSize.height);
        self.clipsToBounds = YES;
        _draggable = YES;
        
        // set image
        _clippy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:pathToImage]];
        _clippy.contentMode = UIViewContentModeScaleAspectFill;
        _clippy.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:_clippy];

        // set sounds
        NSDictionary *soundsAttributes = [self attributesForJSON:pathToSounds];
        NSMutableDictionary *soundsDictionary = [[NSMutableDictionary alloc] init];
        for (NSString *key in [soundsAttributes allKeys]) {
            NSData *audioData = [NSData dataWithBase64EncodedString:soundsAttributes[key]];
            [soundsDictionary setValue:audioData forKey:key];
        }
        _sounds = soundsDictionary;
    }
    
    return self;
}

- (void)show {
    CGSize imageSize = CGSizeMake(_clippy.image.size.width, _clippy.image.size.height);
    CGRect frameRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _clippy.frame = frameRect;
    _clippy.hidden = NO;
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
        animation.sounds = _sounds;
        animation.muted = _muted;
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

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_draggable) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self.superview];
        self.center = location;
    }
}

#pragma mark - Helpers

- (NSDictionary *)attributesForJSON:(NSString *)path {
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:path ofType:nil];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:fullPath] options:0 error:&error];
    
    return JSON;
}

@end