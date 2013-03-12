//
//  NSClippy.m
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import <ImageIO/ImageIO.h>

#import "NSClippy.h"
#import "WZSpriteLayer.h"
#import "WZAnimation.h"
#import "WZFrame.h"
#import "WZAnimator.h"

@interface NSClippy () <WZAnimationDelegate>
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic) CGSize frameSize;
@property (nonatomic, strong) WZSpriteLayer *clippyLayer;
@end

@implementation NSClippy

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    
    if (self) {
        _attributes = attributes;
        _frameSize = CGSizeMake([attributes[@"framesize"][0] integerValue], [attributes[@"framesize"][1] integerValue]);
        self.frame = CGRectMake(0, 0, _frameSize.width, _frameSize.height);
    }
    
    return self;
}

- (void)showAnimation:(NSString *)animationName {
    NSDictionary *animationAttributes = _attributes[@"animations"][animationName];
    
    WZAnimation *animation = [[WZAnimation alloc] initWithAttributes:animationAttributes];
    animation.delegate = self;
    animation.frameSize = _frameSize;
    
    NSString *pathToClippy = [[NSBundle mainBundle] pathForResource:@"Clippy.png" ofType:nil];
    CGImageRef clippyImage = [UIImage imageWithContentsOfFile:pathToClippy].CGImage;
    CGSize imageSize = [self sizeOfImage:pathToClippy];

    if (!_clippyLayer) {
        _clippyLayer = [WZSpriteLayer layerWithImage:clippyImage sampleSize:_frameSize];
        _clippyLayer.position = CGPointMake(0, 0);
        [self.layer addSublayer:_clippyLayer];
    }

    CGFloat time = 0;
    NSMutableArray *animations = [NSMutableArray new];
    
    for (int i = 0; i < animation.frames.count - 1; i++) {
        WZFrame *frame = animation.frames[i];
        WZFrame *nextFrame = animation.frames[i + 1];
        
        CABasicAnimation *coreAnimation = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
        coreAnimation.fromValue = [self indexOfFrameForLocation:frame.images imageSize:imageSize frameSize:_frameSize];
        coreAnimation.toValue = [self indexOfFrameForLocation:nextFrame.images imageSize:imageSize frameSize:_frameSize];
        coreAnimation.duration = frame.duration;
        coreAnimation.repeatCount = 0;
        coreAnimation.beginTime = time;
        
        time = time + frame.duration;
        [animations addObject:coreAnimation];
    }
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = time;
    animationGroup.animations = animations;
    
    [_clippyLayer addAnimation:animationGroup forKey:nil];
}

- (CGSize)sizeOfImage:(NSString *)imagePath {
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
    
    CGFloat width = 0.0f, height = 0.0f;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    if (imageProperties != NULL) {
        CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        if (widthNum != NULL) {
            CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
        }
        
        CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        if (heightNum != NULL) {
            CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
        }
        
        CFRelease(imageProperties);
    }

    return CGSizeMake(width, height);
}

- (NSNumber *)indexOfFrameForLocation:(CGPoint)frameLocation imageSize:(CGSize)imageSize frameSize:(CGSize)frameSize {
    NSInteger x = frameLocation.x / frameSize.width;
    NSInteger y = frameLocation.y / frameSize.height;
    
    NSInteger numberVertically = (imageSize.width / frameSize.width) * y;
    NSInteger numberHorizontally = x;

    return @(numberVertically + numberHorizontally);
}

#pragma mark - WZAnimationDelegate

- (void)animationDidFinish:(NSString *)animationName withState:(WZAnimationState)animationState {
    
}

@end