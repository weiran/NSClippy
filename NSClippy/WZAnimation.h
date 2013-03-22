//
//  WZAnimation.h
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

typedef enum {
    WZAnimationStateWaiting,
    WZAnimationStateExited
} WZAnimationState;

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol WZAnimationDelegate <NSObject>
@optional
- (void)animationDidFinish:(NSString *)animationName withState:(WZAnimationState)animationState;
@end

@interface WZAnimation : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *framesAttributes;
@property (nonatomic) CGSize frameSize;
@property (nonatomic) CGSize imageSize;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) NSDictionary *sounds;
@property (nonatomic) BOOL useExitBranching;
@property (nonatomic) BOOL muted;

@property (nonatomic, weak) id<WZAnimationDelegate> delegate;

- (id)initWithAttributes:(NSDictionary *)attributes;
- (void)play;
- (void)exit;

@end