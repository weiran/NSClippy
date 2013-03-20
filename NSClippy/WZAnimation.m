//
//  WZAnimation.m
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import "WZAnimation.h"
#import "WZFrame.h"
#import "WZBranch.h"

#ifndef MIN
#import <NSObjCRuntime.h>
#endif

@interface WZAnimation () {
    NSInteger _currentFrameIndex;
    WZFrame *_currentFrame;
    NSArray *_internalFrames;
    BOOL _exiting;
}
@end

@implementation WZAnimation

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    
    if (self) {
        _currentFrameIndex = 0;
        _framesAttributes = attributes[@"frames"];
        _exiting = NO;
        
        if ([[attributes allKeys] containsObject:@"useExitBranching"]) {
            NSString *useExitBranching = attributes[@"useExitBranching"];
            _useExitBranching = [useExitBranching isEqualToString:@"true"];
        }
    }
    
    return self;
}

- (void)play {
    _exiting = NO;
    
    // set timeout
    [self performSelector:@selector(exit) withObject:nil afterDelay:10];
    
    [self step];
}

- (void)exit {
    _exiting = YES;
}

- (void)step {
    NSInteger newFrameIndex = MIN([self nextAnimationFrame], _framesAttributes.count - 1);
    BOOL frameChanged = !_currentFrame || _currentFrameIndex != newFrameIndex;
    _currentFrameIndex = newFrameIndex;
    
    NSLog(@"Frame: %d, duration: %f", _currentFrameIndex, _currentFrame.duration);
    
    if (!([self atLastFrame] && _useExitBranching)) {
        _currentFrame = [[WZFrame alloc] initWithAttributes:_framesAttributes[_currentFrameIndex]];
    }
    
    [self showCurrentFrame];
    
    if (![self atLastFrame]) {
        [self performSelector:@selector(step) withObject:nil afterDelay:_currentFrame.duration];
    }
    
    if ([_delegate respondsToSelector:@selector(animationDidFinish:withState:)] && frameChanged && [self atLastFrame]) {
        if (_useExitBranching && !_exiting) {
            [_delegate animationDidFinish:_name withState:WZAnimationStateWaiting];
        } else {
            [_delegate animationDidFinish:_name withState:WZAnimationStateExited];
        }
    }
}

- (NSInteger)nextAnimationFrame {
    if (!_currentFrame) {
        return 0;
    }
    
    WZFrame *currentFrame = [[WZFrame alloc] initWithAttributes:_framesAttributes[_currentFrameIndex]];

    if (_exiting && currentFrame.exitBranchIndex) {
        return [currentFrame.exitBranchIndex integerValue];
    } else if (currentFrame.branches) {
        NSInteger random = arc4random() % 100;
        for (WZBranch *branch in currentFrame.branches) {
            if (random <= branch.weight) {
                return branch.frameIndex;
            }
            
            random -= branch.weight;
        }
    }
    
    return _currentFrameIndex + 1;
}

- (void)showCurrentFrame {
    if (_currentFrame.images) {
        CGPoint point = [_currentFrame.images CGPointValue];
        CGRect frameRect = CGRectMake(-1 * point.x, -1 * point.y, _imageSize.width, _imageSize.height);
        _imageView.frame = frameRect;
        _imageView.hidden = NO;
    } else {
        // hide image view if no image set
        _imageView.hidden = YES;
    }
}

- (BOOL)atLastFrame {
    return _currentFrameIndex >= (int)_framesAttributes.count - 1;
}

@end
