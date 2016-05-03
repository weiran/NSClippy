//
//  WZBranch.m
//  NSClippy
//
//  Created by Weiran Zhang on 10/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import "WZBranch.h"

@implementation WZBranch

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super self];
    
    if (self) {
        self.frameIndex = [attributes[@"frameIndex"] integerValue];
        self.weight = [attributes[@"weight"] integerValue];
    }
    
    return self;
}

@end
