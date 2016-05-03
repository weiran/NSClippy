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
        self.attributes = attributes;
        
        NSInteger durationMiliseconds = [attributes[@"duration"] integerValue];
        self.duration = durationMiliseconds / 1000.0f;
        
        NSArray *imageArray = attributes[@"images"][0];
        if (imageArray) {
            CGPoint imagePoint = CGPointMake([imageArray[0] integerValue], [imageArray[1] integerValue]);
            self.images = [NSValue valueWithCGPoint:imagePoint];
        }
        
        if ([[self.attributes allKeys] containsObject:@"exitBranch"]) {
            self.exitBranchIndex = @([self.attributes[@"exitBranch"] integerValue]);
        }
        
        if ([[self.attributes allKeys] containsObject:@"branching"]) {
            NSArray *branchesAttributes = self.attributes[@"branching"][@"branches"];
            NSMutableArray *branches = [NSMutableArray array];
            
            for (NSDictionary *branchAttributes in branchesAttributes) {
                WZBranch *branch = [[WZBranch alloc] initWithAttributes:branchAttributes];
                [branches addObject:branch];
            }
            
            self.branches = branches;
        }
        
        if ([[self.attributes allKeys] containsObject:@"sound"]) {
            self.sound = self.attributes[@"sound"];
        }
    }
    
    return self;
}

@end
