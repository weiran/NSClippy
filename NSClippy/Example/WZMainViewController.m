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
@property (nonatomic, strong) NSClippy *clippy;
@end

@implementation WZMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showAnimation:(UIButton *)sender {
    if (!_clippy) {
        _clippy = [[NSClippy alloc] initWithAgent:@"clippy"];
        _clippy.frame = CGRectMake(100, 100, _clippy.frame.size.width, _clippy.frame.size.height);
        [self.view addSubview:_clippy];
    }
    
    [_clippy showAnimation:sender.titleLabel.text];
}

- (IBAction)stopAnimation:(id)sender {
    [_clippy exitAnimation];
}
@end
