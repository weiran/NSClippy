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

@implementation NSClippy





- (void)presentInLayer:(CALayer *)layer {
    NSString *pathToClippy = [[NSBundle mainBundle] pathForResource:@"Clippy.png" ofType:nil];
    CGImageRef clippyImage = [UIImage imageWithContentsOfFile:pathToClippy].CGImage;
    CGSize fixedSize = CGSizeMake(124, 93);
    WZSpriteLayer *clippy = [WZSpriteLayer layerWithImage:clippyImage sampleSize:fixedSize];
    clippy.position = CGPointMake(100,100);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
    animation.fromValue = @1;
    animation.toValue = @9;
    animation.duration = 0.75;
    animation.repeatCount = HUGE_VALF;
    
    [clippy addAnimation:animation forKey:nil];
    [layer addSublayer:clippy];
}

- (void)doCongratulate:(CALayer *)layer {
    NSString *pathToClippyJSON = [[NSBundle mainBundle] pathForResource:@"Clippy.json" ofType:nil];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:pathToClippyJSON] options:0 error:nil];
    
//    for (NSString *animationName in jsonData[@"animations"]) {
//        NSDictionary *animationAttributes = jsonData[@"animations"][animationName];
//        WZAnimation *animation = [[WZAnimation alloc] initWithAttributes:animationAttributes];
//    }
    
    NSDictionary *animationAttributes = jsonData[@"animations"][@"SendMail"];
    WZAnimation *animation = [[WZAnimation alloc] initWithAttributes:animationAttributes];
    
    CGSize frameSize = CGSizeMake([jsonData[@"framesize"][0] integerValue], [jsonData[@"framesize"][1] integerValue]);
        
    NSString *pathToClippy = [[NSBundle mainBundle] pathForResource:@"Clippy.png" ofType:nil];
    CGImageRef clippyImage = [UIImage imageWithContentsOfFile:pathToClippy].CGImage;
    CGSize imageSize = [self sizeOfImage:pathToClippy];

    WZSpriteLayer *clippy = [WZSpriteLayer layerWithImage:clippyImage sampleSize:frameSize];
    clippy.position = CGPointMake(100,100);

    CGFloat time = 0;
    NSMutableArray *animations = [NSMutableArray new];
    
    for (int i = 0; i < animation.frames.count - 1; i++) {
        WZFrame *frame = animation.frames[i];
        WZFrame *nextFrame = animation.frames[i + 1];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
        animation.fromValue = [self indexOfFrameForLocation:frame.images imageSize:imageSize frameSize:frameSize];
        animation.toValue = [self indexOfFrameForLocation:nextFrame.images imageSize:imageSize frameSize:frameSize];
        animation.duration = frame.duration;
        animation.repeatCount = 0;
        animation.beginTime = time;
        
        time = time + frame.duration;
        [animations addObject:animation];
    }
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = time;
    animationGroup.animations = animations;
    
    [clippy addAnimation:animationGroup forKey:nil];
    [layer addSublayer:clippy];
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

@end