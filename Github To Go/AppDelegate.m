//
//  AppDelegate.m
//  Github To Go
//
//  Created by Robert Panzer on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Repository.h"
#import "NetworkProxy.h"
#import "RepoBrowserTableViewController.h"
#import "SettingsViewController.h"
#import "EventTableViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UINavigationBar appearance] setTintColor:[UIColor darkGrayColor]];
    [[UIToolbar appearance] setTintColor:[UIColor darkGrayColor]];
    [[UILabel appearance] setFont:[UIFont systemFontOfSize:13.0f]];
//    [[UITableView appearance] setBackgroundColor:[UIColor blackColor]];
//    [[UITableView appearance] setBackgroundColor:[UIColor blackColor]];
//    [[UITableViewCell appearance] setBackgroundColor:[UIColor whiteColor]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    EventTableViewController *eventTableViewController = [[EventTableViewController alloc] initWithAllEvents];
    UINavigationController *eventsNavigationController = [[UINavigationController alloc] initWithRootViewController:eventTableViewController];

    RepoBrowserTableViewController* repoBrowserController = [[RepoBrowserTableViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:repoBrowserController];
    
    SettingsViewController* settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:eventsNavigationController, navigationController, settingsController, nil];
    self.window.rootViewController = self.tabBarController;
        
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [Person clearCache];
}
/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
