//
//  WZMainViewController.m
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#import "WZMainViewController.h"

#import "NSClippy.h"

@interface WZMainViewController ()

@end

@implementation WZMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSClippy *clippy = [[NSClippy alloc] init];
    [clippy doCongratulate:self.view.layer];
}

@end
