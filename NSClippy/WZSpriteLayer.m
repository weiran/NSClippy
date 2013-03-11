//
//  WZSpriteLayer.m
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//
//  Based on MCSpriteLayer by Mystery Coconut: http://mysterycoconut.com/blog/2011/01/cag1/
//

#import <QuartzCore/QuartzCore.h>

#import "WZSpriteLayer.h"

@implementation WZSpriteLayer

#pragma mark - Initialization, variable sample size

- (id)initWithImage:(CGImageRef)image {
    self = [super init];
    
    if (self) {
        self.contents = (__bridge id)(image);
        _sampleIndex = 1;
    }
    
    return self;
}


+ (id)layerWithImage:(CGImageRef)image;
{
    return [[self alloc] initWithImage:(__bridge UIImage *)(image)];
}


#pragma mark - Initialization, fixed sample size

- (id)initWithImage:(CGImageRef)image sampleSize:(CGSize)size {
    self = [self initWithImage:image];
    
    if (self) {
        CGSize sampleSizeNormalized = CGSizeMake(size.width / CGImageGetWidth(image), size.height / CGImageGetHeight(image));
        self.bounds = CGRectMake(0, 0, size.width, size.height);
        self.contentsRect = CGRectMake(0, 0, sampleSizeNormalized.width, sampleSizeNormalized.height);
    }
    
    return self;
}


+ (id)layerWithImage:(CGImageRef)image sampleSize:(CGSize)size {
    return [[self alloc] initWithImage:image sampleSize:size];
}


#pragma mark -
#pragma mark Frame by frame animation


+ (BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"sampleIndex"];
}


// contentsRect or bounds changes are not animated
+ (id <CAAction>)defaultActionForKey:(NSString *)aKey {
    if ([aKey isEqualToString:@"contentsRect"] || [aKey isEqualToString:@"bounds"]) {
        return (id <CAAction>)[NSNull null];
    }
    
    return [super defaultActionForKey:aKey];
}


- (unsigned int)currentSampleIndex; {
    return ((WZSpriteLayer *)self.presentationLayer).sampleIndex;
}


// Implement displayLayer: on the delegate to override how sample rectangles are calculated; remember to use currentSampleIndex, ignore sampleIndex == 0, and set the layer's bounds
- (void)display {
    if ([self.delegate respondsToSelector:@selector(displayLayer:)]) {
        [self.delegate displayLayer:self];
        return;
    }
    
    unsigned int currentSampleIndex = [self currentSampleIndex];
    if (!currentSampleIndex) {
        return;
    }
    
    CGSize sampleSize = self.contentsRect.size;
    self.contentsRect = CGRectMake(
                                   ((currentSampleIndex - 1) % (int)(1/sampleSize.width)) * sampleSize.width,
                                   ((currentSampleIndex - 1) / (int)(1/sampleSize.width)) * sampleSize.height,
                                   sampleSize.width, sampleSize.height
                                   );
}

@end
