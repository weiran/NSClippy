//
//  NSClippy.h
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface NSClippy : CALayer

@property (nonatomic, strong) NSDictionary *framesDictionary;


- (void)presentInLayer:(CALayer *)layer;
- (void)doCongratulate:(CALayer *)layer;
@end
