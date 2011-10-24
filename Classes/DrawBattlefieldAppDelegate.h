//
//  DrawBattlefieldAppDelegate.h
//  DrawBattlefield
//
//  Created by James Washburn on 5/13/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// DrawBattlefield App Delegate, stores vibrate option

#import <UIKit/UIKit.h>
#import <UIKit/UIScreen.h>
#import "OpenFeintDelegate.h"

@interface DrawBattlefieldAppDelegate : NSObject <UIApplicationDelegate, UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, OpenFeintDelegate> {
    UIWindow *window;
	BOOL vibrateOptionOff;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, assign) BOOL vibrateOptionOff;

- (void) applicationWillResignActive:(UIApplication *)application;
- (void) applicationDidBecomeActive:(UIApplication *)application;
- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application;
- (void) applicationSignificantTimeChange:(UIApplication *)application;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)dashboardDidAppear;
- (void)dashboardDidDisappear;


@end

