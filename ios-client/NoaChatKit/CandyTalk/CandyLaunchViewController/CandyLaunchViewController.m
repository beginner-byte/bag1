//
//  NILaunchViewController.m
//  NoaKit
//
//  Created by 郑开 on 2024/3/7.
//

#import "CandyLaunchViewController.h"

@interface CandyLaunchViewController ()

@end

@implementation CandyLaunchViewController

- (instancetype)init{
    id  controller;
    controller = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil].instantiateInitialViewController;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
