//
//  WZFrame.h
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZFrame : NSObject

@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic) CGFloat duration;
@property (nonatomic, strong) NSValue *images;
@property (nonatomic, strong) NSNumber *exitBranchIndex;
@property (nonatomic, strong) NSArray *branches;
@property (nonatomic, strong) NSString *sound;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
