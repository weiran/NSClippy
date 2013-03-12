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
#import "WZAnimator.h"

@interface NSClippy () <WZAnimationDelegate>
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic) CGSize frameSize;
@property (nonatomic, strong) UIImageView *clippy;
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
    NSString *pathToClippy = [[NSBundle mainBundle] pathForResource:@"Clippy.png" ofType:nil];
    CGSize imageSize = [self sizeOfImage:pathToClippy];
    
    
    WZAnimation *animation = [[WZAnimation alloc] initWithAttributes:animationAttributes];
    animation.delegate = self;
    animation.frameSize = _frameSize;
    animation.imageSize = imageSize;
    
    if (!_clippy) {
        _clippy = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Clippy.png"]];
        _clippy.contentMode = UIViewContentModeScaleAspectFill;
        _clippy.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:_clippy];
    }
    
//    CGRect newFrame = CGRectOffset(_clippy.frame, -10, -10);
//    _clippy.frame = newFrame;
    
    self.clipsToBounds = YES;
    
    animation.imageView = _clippy;
    [animation showAnimation];
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

//- (NSNumber *)indexOfFrameForLocation:(CGPoint)frameLocation imageSize:(CGSize)imageSize frameSize:(CGSize)frameSize {
//    NSInteger x = frameLocation.x / frameSize.width;
//    NSInteger y = frameLocation.y / frameSize.height;
//    
//    NSInteger numberVertically = (imageSize.width / frameSize.width) * y;
//    NSInteger numberHorizontally = x;
//
//    return @(numberVertically + numberHorizontally);
//}

@end