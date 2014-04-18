//
//  MainTabBarViewController.m
//  Hub To Go
//
//  Created by Robert Panzer on 14.09.13.
//
//

#import "MainTabBarViewController.h"
#import "EventRootViewController.h"
#import "RepoBrowserTableViewController.h"
#import "SearchTableViewController.h"
#import "SettingsViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    EventRootViewController *eventRootViewController = [[EventRootViewController alloc] init];
    UINavigationController *eventsNavigationController = [[UINavigationController alloc] initWithRootViewController:eventRootViewController];
    eventsNavigationController.navigationBar.translucent = NO;
    
    RepoBrowserTableViewController* repoBrowserController = [[RepoBrowserTableViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:repoBrowserController];
    navigationController.navigationBar.translucent = NO;
    
    UINavigationController *searchTableViewController = [[UINavigationController alloc] initWithRootViewController:[[SearchTableViewController alloc] init]];
    searchTableViewController.navigationBar.translucent = NO;
    
    SettingsViewController* settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    

    self.viewControllers = @[
                             eventsNavigationController,
                             navigationController,
                             searchTableViewController,
                             settingsController];
    eventRootViewController.tabBarItem = self.tabBar.items[0];


}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[self class] instancesRespondToSelector:@selector(setEdgesForExtendedLayout:)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.view.frame = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
    }
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
