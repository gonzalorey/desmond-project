//
//  AppDelegate.m
//  desmond-project
//
//  Created by David Grandes on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "IAPHelper.h"

#import "ViewController.h"
#import <GameKit/GameKit.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver: [IAPHelper sharedHelper]];
    
    [self authenticateLocalPlayer];
    
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
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"intervalDate"]) {
        
        UILocalNotification * localNotif = [[UILocalNotification alloc] init];
        
        if (localNotif) {
            localNotif.fireDate = [defaults objectForKey:@"intervalDate"];
            localNotif.alertBody = [NSString stringWithFormat:@"The world is over! At least you saved it %d times...",[defaults integerForKey:@"level"]];
            localNotif.alertAction = @"View";
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.userInfo = [NSDictionary dictionaryWithObject:@"lost" forKey:@"type"];
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        }
    }
    
    if ([defaults integerForKey:@"totalReminders"] > 0) {
        UILocalNotification * localNotif = [[UILocalNotification alloc] init];
        
        if (localNotif) {
            NSDate * reminderDate = [NSDate dateWithTimeInterval:-(4*60) sinceDate:[defaults objectForKey:@"intervalDate"]];
            localNotif.fireDate = reminderDate;
            localNotif.alertBody = [NSString stringWithFormat:@"You have less than 4 minutes left to save the world!!! GO!!!!!"];
            localNotif.alertAction = @"GO!";
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.userInfo = [NSDictionary dictionaryWithObject:@"reminder" forKey:@"type"];
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        }
    }
    
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
	
	if ([[notification.userInfo objectForKey:@"type"] isEqualToString:@"reminder"]) {
        //decrement reminders
        int remindersLeft = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalReminders"];
        remindersLeft--;
        
        [[NSUserDefaults standardUserDefaults] setInteger:remindersLeft forKey:@"totalReminders"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseRemaindersAmount object:nil];
    }    
	
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
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void) authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error authenticating: %@",[error localizedDescription]);
        }
        if (localPlayer.isAuthenticated)
        {
            // Perform additional tasks for the authenticated player.
            NSLog(@"Authenticated: %@",localPlayer.alias);
        }
    }];
}

@end
