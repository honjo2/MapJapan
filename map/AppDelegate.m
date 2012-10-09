//
//  AppDelegate.m
//  map
//
//  Created by honjo2 on 2012/09/28.
//  Copyright (c) 2012年 honjo2. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  
  UINavigationController *navigationController = (UINavigationController *)_window.rootViewController;
  NSArray *controllers = navigationController.viewControllers;
  ViewController *controller = [controllers objectAtIndex:0];
  //  NSLog(@"c:%@", controller.mapView);
  MMMapView *mapView = controller.mapView;
  
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  [ud setFloat:mapView.centerCoordinate.latitude forKey:kLastLatitude];
  [ud setFloat:mapView.centerCoordinate.longitude forKey:kLastLongitude];
  [ud setFloat:mapView.zoom forKey:kLastZoom];
  
  for (int i = 0; i < kMaxAnnotationsCount; i++) {
    [ud removeObjectForKey:[NSString stringWithFormat:kAnnotationAddress, i]];
  }
  
  int offset = 0;
  for (MMAnnotationView *anno in mapView.annotations) {
    if (anno.tag != kSelfPinTag) continue;
    [ud setObject:anno.title forKey:[NSString stringWithFormat:kAnnotationAddress, offset]];
    [ud setFloat:anno.coordinate.latitude forKey:[NSString stringWithFormat:kAnnotationLatitude, offset]];
    [ud setFloat:anno.coordinate.longitude forKey:[NSString stringWithFormat:kAnnotationLongitude, offset]];
    offset++;
  }
  
  [ud synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
