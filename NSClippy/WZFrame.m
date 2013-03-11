//
//  WZFrame.m
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import "WZFrame.h"
#import "WZBranch.h"

@implementation WZFrame

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    
    if (self) {
        _attributes = attributes;
        
        NSInteger durationMiliseconds = [attributes[@"duration"] integerValue];
        _duration = durationMiliseconds / 1000.0f;
        
        NSArray *imageArray = attributes[@"images"][0];
        _images = CGPointMake([imageArray[0] integerValue], [imageArray[1] integerValue]);
        
        if ([[_attributes allKeys] containsObject:@"exitBranch"]) {
            _exitBranchIndex = @([_attributes[@"exitBranch"] integerValue]);
        }
        
        if ([[_attributes allKeys] containsObject:@"branching"]) {
            NSArray *branchesAttributes = _attributes[@"branching"][@"branches"];
            NSMutableArray *branches = [NSMutableArray array];
            
            for (NSDictionary *branchAttributes in branchesAttributes) {
                WZBranch *branch = [[WZBranch alloc] initWithAttributes:branchAttributes];
                [branches addObject:branch];
            }
            
            _branches = branches;
        }
    }
    
    return self;
}

@end
