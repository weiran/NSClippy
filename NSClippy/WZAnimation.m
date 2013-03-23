//
//  WZAnimation.m
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

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
    AVAudioPlayer *_audioPlayer;
}
@end

@implementation WZAnimation

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    
    if (self) {
        _currentFrameIndex = 0;
        _framesAttributes = attributes[@"frames"];
        _exiting = NO;
        _muted = NO;
        
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
    dispatch_async(dispatch_get_main_queue(), ^{
        _exiting = YES;
    });
}

- (void)step {
    NSInteger newFrameIndex = MIN([self nextAnimationFrame], _framesAttributes.count - 1);
    BOOL frameChanged = !_currentFrame || _currentFrameIndex != newFrameIndex;
    _currentFrameIndex = newFrameIndex;
        
    if (!([self atLastFrame] && _useExitBranching)) {
        _currentFrame = [[WZFrame alloc] initWithAttributes:_framesAttributes[_currentFrameIndex]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showCurrentFrame];
        [self playCurrentFrameSound];
    });
    
    if (![self atLastFrame]) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_currentFrame.duration * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self step];
        });
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

- (void)playCurrentFrameSound {
    if (_currentFrame.sound && !_muted) {
        NSError *error = nil;
        NSData *sound = (NSData *)_sounds[_currentFrame.sound];
        
        // write the NSData audio to disk as AVAudioPlayer is better at reading from disk
        NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3", docDirPath , [NSString stringWithFormat:@"%@_audio", _currentFrame.sound]];
        [sound writeToFile:filePath atomically:YES];
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
        _audioPlayer.delegate = self;
        
        if (!error) {
            [_audioPlayer play];
        } else {
            NSLog(@"Error playing sound: %@", _currentFrame.sound);
        }
    }
}

- (BOOL)atLastFrame {
    return _currentFrameIndex >= (int)_framesAttributes.count - 1;
}

@end
