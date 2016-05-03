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
        self.attributes = [self attributesForJSON:pathToAnimations];
        self.frameSize = CGSizeMake([self.attributes[@"framesize"][0] integerValue], [self.attributes[@"framesize"][1] integerValue]);
        self.frame = CGRectMake(0, 0, self.frameSize.width, self.frameSize.height);
        self.clipsToBounds = YES;
        self.draggable = YES;
        
        // set image
        self.clippy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:pathToImage]];
        self.clippy.contentMode = UIViewContentModeScaleAspectFill;
        self.clippy.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:self.clippy];

        // set sounds
        NSDictionary *soundsAttributes = [self attributesForJSON:pathToSounds];
        NSMutableDictionary *soundsDictionary = [[NSMutableDictionary alloc] init];
        for (NSString *key in [soundsAttributes allKeys]) {
            NSData *audioData = [NSData dataWithBase64EncodedString:soundsAttributes[key]];
            [soundsDictionary setValue:audioData forKey:key];
        }
        self.sounds = soundsDictionary;
    }
    
    return self;
}

- (void)show {
    CGSize imageSize = CGSizeMake(self.clippy.image.size.width, self.clippy.image.size.height);
    CGRect frameRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.clippy.frame = frameRect;
    self.clippy.hidden = NO;
}

- (void)showAnimation:(NSString *)animationName {
    if (!self.currentAnimation) {
        NSDictionary *animationAttributes = self.attributes[@"animations"][animationName];
        CGSize imageSize = CGSizeMake(self.clippy.image.size.width, self.clippy.image.size.height);
        
        WZAnimation *animation = [[WZAnimation alloc] initWithAttributes:animationAttributes];
        animation.delegate = self;
        animation.frameSize = self.frameSize;
        animation.imageSize = imageSize;
        animation.imageView = self.clippy;
        animation.sounds = self.sounds;
        animation.muted = self.muted;
        self.currentAnimation = animation;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           [animation play]; 
        });
    }
}

- (void)exitAnimation {
    [self.currentAnimation exit];
}

#pragma mark - WZAnimationDelegate

- (void)animationDidFinish:(NSString *)animationName withState:(WZAnimationState)animationState {
    if (animationState == WZAnimationStateExited) {
        self.currentAnimation = nil;
    }
}

#pragma mark - UIView

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.draggable) {
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