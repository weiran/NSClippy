//
//  WZAnimation.m
//  NSClippy;
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

@interface WZAnimation ()

@property (nonatomic) NSInteger currentFrameIndex;
@property (nonatomic, strong) WZFrame *currentFrame;
@property (nonatomic, strong) NSArray *internalFrames;
@property (nonatomic) BOOL exiting;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation WZAnimation

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    
    if (self) {
        self.currentFrameIndex = 0;
        self.framesAttributes = attributes[@"frames"];
        self.exiting = NO;
        self.muted = NO;
        
        if ([[attributes allKeys] containsObject:@"useExitBranching"]) {
            NSString *useExitBranching = attributes[@"useExitBranching"];
            self.useExitBranching = [useExitBranching isEqualToString:@"true"];
        }
    }
    
    return self;
}

- (void)play {
    self.exiting = NO;
    
    // set timeout
    int timeout = 5; // in seconds
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(exit) withObject:nil afterDelay:timeout];
    });
    
    [self step];
}

- (void)exit {
    self.exiting = YES;
}

- (void)step {
    NSInteger newFrameIndex = MIN([self nextAnimationFrame], self.framesAttributes.count - 1);
    BOOL frameChanged = !self.currentFrame || self.currentFrameIndex != newFrameIndex;
    self.currentFrameIndex = newFrameIndex;
        
    if (!([self atLastFrame] && self.useExitBranching)) {
        self.currentFrame = [[WZFrame alloc] initWithAttributes:self.framesAttributes[_currentFrameIndex]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showCurrentFrame];
        [self playCurrentFrameSound];
    });
    
    if (![self atLastFrame]) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.currentFrame.duration * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self step];
        });
    }
    
    if ([self.delegate respondsToSelector:@selector(animationDidFinish:withState:)] && frameChanged && [self atLastFrame]) {
        if (self.useExitBranching && !self.exiting) {
            [self.delegate animationDidFinish:self.name withState:WZAnimationStateWaiting];
        } else {
            [self.delegate animationDidFinish:self.name withState:WZAnimationStateExited];
        }
    }
}

- (NSInteger)nextAnimationFrame {
    if (!self.currentFrame) {
        return 0;
    }
    
    WZFrame *currentFrame = [[WZFrame alloc] initWithAttributes:self.framesAttributes[self.currentFrameIndex]];

    if (self.exiting && currentFrame.exitBranchIndex) {
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
    
    return self.currentFrameIndex + 1;
}

- (void)showCurrentFrame {
    if (self.currentFrame.images) {
        CGPoint point = [self.currentFrame.images CGPointValue];
        CGRect frameRect = CGRectMake(-1 * point.x, -1 * point.y, self.imageSize.width, self.imageSize.height);
        self.imageView.frame = frameRect;
        self.imageView.hidden = NO;
    } else {
        // hide image view if no image set
        self.imageView.hidden = YES;
    } 
}

- (void)playCurrentFrameSound {
    if (self.currentFrame.sound && !self.muted) {
        NSError *error = nil;
        NSData *sound = (NSData *)self.sounds[self.currentFrame.sound];
        
        // write the NSData audio to disk as AVAudioPlayer is better at reading from disk
        NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3", docDirPath , [NSString stringWithFormat:@"%@_audio", self.currentFrame.sound]];
        [sound writeToFile:filePath atomically:YES];
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
        self.audioPlayer.delegate = self;
        
        if (!error) {
            [self.audioPlayer play];
        } else {
            NSLog(@"Error playing sound: %@", self.currentFrame.sound);
        }
    }
}

- (BOOL)atLastFrame {
    return self.currentFrameIndex >= (int)self.framesAttributes.count - 1;
}

@end
