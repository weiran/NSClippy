//
//  WZMainViewController.m
//  NSClippy
//
//  Created by Weiran Zhang on 07/03/2013.
//  Copyright (c) 2013 Weiran Zhang. All rights reserved.
//

#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#else
#define IS_IPAD NO
#endif

#import "WZMainViewController.h"
#import "NSClippy.h"

@interface WZMainViewController ()
@property (nonatomic, strong) NSClippy *clippy;

@property (nonatomic, strong) NSArray *animations;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation WZMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _clippy = [[NSClippy alloc] initWithAgent:@"clippy"];
    _clippy.frame = CGRectMake(100, 100, _clippy.frame.size.width, _clippy.frame.size.height);
    [self.view addSubview:_clippy];

    [_clippy show];

    if (!IS_IPAD) {
        NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"clippy-animations.json" ofType:nil];
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:fullPath] options:0 error:nil];
        _animations = [JSON[@"animations"] allKeys];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - iPad

- (IBAction)showAnimation:(UIButton *)sender {
    [_clippy showAnimation:sender.titleLabel.text];
}

- (IBAction)stopAnimation:(id)sender {
    [_clippy exitAnimation];
}

#pragma mark - iPhone

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _animations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnimationCell"];
    cell.textLabel.text = _animations[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [_clippy showAnimation:cell.textLabel.text];
    
    [self performSelector:@selector(deselectCell:) withObject:cell afterDelay:0.3];
}

- (void)deselectCell:(UITableViewCell *)cell {
    cell.selected = NO;
}

@end
