//
//  SPLAppDelegate.m
//  SPLFormViewController
//
//  Created by CocoaPods on 12/30/2014.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLAppDelegate.h"
#import "SPLViewController.h"

@implementation SPLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[SPLViewController alloc] init] ];
    [self.window makeKeyAndVisible];

    return YES;
}

@end
