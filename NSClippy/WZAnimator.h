//
//  WZAnimator.h
//  NSClippy
//
//  Created by Weiran Zhang on 12/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WZAnimation;

@interface WZAnimator : NSObject

- (void)animate:(WZAnimation *)animation inLayer:(CALayer *)layer onCompletion:(void (^)(void))completion;

@end
