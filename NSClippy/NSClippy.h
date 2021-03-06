//
//  NSClippy.h
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface NSClippy : UIView

@property (nonatomic) BOOL muted;
@property (nonatomic) BOOL draggable;

- (id)initWithAgent:(NSString *)agent;
- (void)show;
- (void)showAnimation:(NSString *)animationName;
- (void)exitAnimation;

@end
