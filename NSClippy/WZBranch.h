//
//  WZBranch.h
//  NSClippy
//
//  Created by Weiran Zhang on 10/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZBranch : NSObject

@property (nonatomic) NSInteger frameIndex;
@property (nonatomic) NSInteger weight;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
