//
//  DrawBattlefieldAppDelegate.m
//  DrawBattlefield
//
//  Created by James Washburn on 5/13/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
// 

#import "DrawBattlefieldAppDelegate.h"
#import "OpenFeint.h"
#import "cocos2d.h"
#import "MainMenuLayer.h"
#import "chipmunk.h"
#import "factions.h"



@implementation DrawBattlefieldAppDelegate

@synthesize window;
@synthesize vibrateOptionOff;

//- (void) applicationDidFinishLaunching:(UIApplication*)application{
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any other call to the director
	[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];
	
	// before creating any layer, set the landscape mode
	CCDirector *director = [CCDirector sharedDirector];
	
	// landscape orientation
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// set FPS at 60
	[director setAnimationInterval:1.0/60];
	
	// Display FPS: yes
	[director setDisplayFPS:YES];
	
	// Create an EAGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8                // RGBA8 color buffer
								   depthFormat:GL_DEPTH_COMPONENT24_OES   // 24-bit depth buffer
							preserveBackbuffer:NO];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	[[CCDirector sharedDirector] setContentScaleFactor:2];
	
	// make the OpenGLView a child of the main window
	[window addSubview:glView];
	
	// make main window visible
	[window makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Vibrate option detection
	if ([[NSUserDefaults standardUserDefaults]  objectForKey:@"vibrateOptionOff"]) {
		self.vibrateOptionOff = NO;
	}
	self.vibrateOptionOff = [[NSUserDefaults standardUserDefaults]  boolForKey:@"vibrateOptionOff"];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	// Initialize Chipmunk Physics
	cpInitChipmunk();
	
	// Seed random number generator
	srandom((unsigned int) [NSDate timeIntervalSinceReferenceDate]);
	
		
	//[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
	
	// show FPS
	[[CCDirector sharedDirector] setDisplayFPS:YES];
	
	/*// Display the previous image to transition properly
	CCSprite *sprite = [[CCSprite spriteWithFile:@"Default.png"] retain];
	sprite.anchorPoint = CGPointZero;
	[sprite draw];	
	[[[CCDirector sharedDirector] openGLView] swapBuffers];
	[sprite release];*/
	
	// Preload unit textures	
	CCTextureCache *textureManager = [CCTextureCache sharedTextureCache];
	[textureManager addPVRTCImage:@"tanklight.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"tankheavy.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"turretlight.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"turretheavy.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"soldier.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"soldierofficer.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"soldierarmored.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"soldierrocket.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"poweredarmor.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"sniper.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"soldierdrill.pvrtc" bpp:4 hasAlpha:YES width:128];
	[textureManager addPVRTCImage:@"shield.pvrtc" bpp:4 hasAlpha:YES width:128];

	// Window setup
	
	[self performSelector:@selector(delayedInitialization:) withObject:nil afterDelay:0.1];
	
	return YES;
}

- (void) delayedInitialization:(id)data {
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	UIInterfaceOrientation orientationOF = UIInterfaceOrientationLandscapeLeft;
	ccDeviceOrientation orientationCC = CCDeviceOrientationLandscapeLeft;
	
	if (orientation == UIDeviceOrientationLandscapeRight) {
		orientationCC = CCDeviceOrientationLandscapeRight;
		orientationOF = UIInterfaceOrientationLandscapeRight;
		
	} else if ((orientation == UIDeviceOrientationPortrait) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		orientationCC = CCDeviceOrientationPortrait;
		orientationOF = UIInterfaceOrientationPortrait;
		
	} else if ((orientation == UIDeviceOrientationPortraitUpsideDown) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		orientationCC = CCDeviceOrientationPortraitUpsideDown;
		orientationOF = UIInterfaceOrientationPortraitUpsideDown;
	}
	
	[[CCDirector sharedDirector] setDeviceOrientation:orientationCC];
	
	// To use High-Res un comment the following line
	
	// Settings for OpenFeint
	NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:orientationOF], OpenFeintSettingDashboardOrientation,
							  @"DrawBattle", OpenFeintSettingShortDisplayName, 
							  [NSNumber numberWithBool:YES], OpenFeintSettingEnablePushNotifications,
							  nil];
	
	
	// Delegates for OpenFeint
	OFDelegatesContainer* delegates = [OFDelegatesContainer containerWithOpenFeintDelegate:self
																	  andChallengeDelegate:nil
																   andNotificationDelegate:nil]; 
	// Initialize OpenFeint
	[OpenFeint initializeWithProductKey:@"ibmMwmpBE58hp24LgAl1TQ" 
							  andSecret:@"migk0mMG2UfB5TH2h9O2ZWR2mAM84pAeAiuScuHTg"
						 andDisplayName:@"DrawBattlefield"
							andSettings:settings
						   andDelegates:delegates];
	
	// create the main scene
	CCScene *scene = [MainMenuLayer node];
	
	// and run it!
	[[CCDirector sharedDirector] runWithScene: scene];
	
}

// getting a call, pause the game
- (void) applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
	[OpenFeint applicationWillResignActive];
}

// call got rejected
- (void) applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
	[OpenFeint applicationDidBecomeActive];
}

// purge textures to clear memory
- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

// next delta time will be zero
- (void) applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [OpenFeint applicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    OFLog([NSString stringWithFormat:@"Failed to register for remote notifications with error: %@", [error localizedDescription]]);
    [OpenFeint applicationDidFailToRegisterForRemoteNotifications];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [OpenFeint applicationDidReceiveRemoteNotification:userInfo];
}


// OpenFeint dashboard appeared, pause the game
- (void) dashboardDidAppear {
	[[CCDirector sharedDirector] pause];
}

// OpenFeint dashboard disappeared
- (void) dashboardDidDisappear {
	[[CCDirector sharedDirector] resume];
}

- (void) dealloc {
    [window release];
    [super dealloc];
}


@end
