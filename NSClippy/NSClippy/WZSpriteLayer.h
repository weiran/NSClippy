//
//  WZSpriteLayer.h
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface WZSpriteLayer : CALayer

// SampleIndex needs to be > 0
@property (readwrite, nonatomic) unsigned int sampleIndex;

// For use with sample rects set by the delegate
+ (id)layerWithImage:(CGImageRef)img;
- (id)initWithImage:(CGImageRef)img;

// If all samples are the same size
+ (id)layerWithImage:(CGImageRef)img sampleSize:(CGSize)size;
- (id)initWithImage:(CGImageRef)img sampleSize:(CGSize)size;

// Use this method instead of sprite.sampleIndex to obtain the index currently displayed on screen
- (unsigned int)currentSampleIndex;

@end
