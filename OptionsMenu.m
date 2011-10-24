//
//  OptionsMenu.m
//  DrawBattlefield
//
//  Created by James Washburn on 5/18/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import "OptionsMenu.h"

#import "DrawBattlefieldAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MainMenuLayer.h"
#import "Battleground.h"

@implementation OptionsMenu

-(id) init
{
	[super init];
	
	NSString *deviceType = [UIDevice currentDevice].model;
	BOOL canVibrate = NO;
	if([deviceType isEqualToString:@"iPhone"]){
		canVibrate = YES;
	}
	
	/*[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:40];
	MenuItemFont *title1 = [MenuItemFont itemFromString: @"Sound"];
    [title1 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item1 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"On"],
                             [MenuItemFont itemFromString: @"Off"],
                             nil];
    
	[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:18];
	MenuItemFont *title2 = [MenuItemFont itemFromString: @"Music"];
    [title2 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item2 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"On"],
                             [MenuItemFont itemFromString: @"Off"],
                             nil];
    */
	
	[CCMenuItemFont setFontName: @"American Typewriter"];
	[CCMenuItemFont setFontSize:18];
	CCMenuItemFont *highres = [CCMenuItemFont itemFromString: @"High Resolution"];
    [highres setIsEnabled:NO];
	[CCMenuItemFont setFontName: @"Marker Felt"];
	[CCMenuItemFont setFontSize:34];
    CCMenuItemToggle *highres2 = [CCMenuItemToggle itemWithTarget:self selector:@selector(highResCallback:) items:
                             [CCMenuItemFont itemFromString: @"On"],
                             [CCMenuItemFont itemFromString: @"Off"],
                             nil];
	
	CCMenuItemFont *title3 = nil;
	CCMenuItemToggle *item3 = nil;
	
	if (canVibrate) {
		[CCMenuItemFont setFontName: @"American Typewriter"];
		[CCMenuItemFont setFontSize:35];
		title3 = [CCMenuItemFont itemFromString: @"Vibrate"];
		[title3 setIsEnabled:NO];
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		item3 = [CCMenuItemToggle itemWithTarget:self selector:@selector(vibrateCallback:) items:
								 [CCMenuItemFont itemFromString: @"On"],
								 [CCMenuItemFont itemFromString: @"Off"],
								 nil];
		
		BOOL vibrateOptionOff = [[NSUserDefaults standardUserDefaults]  boolForKey:@"vibrateOptionOff"];
		
		if (vibrateOptionOff){
			item3.selectedIndex = 1;
		}
	}
	
	
	
	//[MenuItemFont setFontName: @"American Typewriter"];
	//[MenuItemFont setFontSize:35];
	/*MenuItemFont *title4 = [MenuItemFont itemFromString: @"Volume"];
    [title4 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item4 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"Off"], nil];
	
	NSArray *more_items = [NSArray arrayWithObjects:
						   [MenuItemFont itemFromString: @"33%"],
						   [MenuItemFont itemFromString: @"66%"],
						   [MenuItemFont itemFromString: @"100%"],
						   nil];
	// TIP: you can manipulate the items like any other NSMutableArray
	[item4.subItems addObjectsFromArray: more_items];
	
    // you can change the one of the items by doing this
    item4.selectedIndex = 0;
	
	item4.isEnabled = NO;*/
    
    [CCMenuItemFont setFontName: @"Marker Felt"];
	[CCMenuItemFont setFontSize:34];
	CCMenuItemFont *reset = [CCMenuItemFont itemFromString: @"Reset Saved Data" target:self selector:@selector(resetSavedDataCallback:)];

	[CCMenuItemFont setFontSize:40];
	CCMenuItemFont *back = [CCMenuItemFont itemFromString: @"Go Back" target:self selector:@selector(backCallback:)];
	[CCMenuItemFont setFontSize:34];

	CCMenu *menu = nil;
	
	if (canVibrate) {
		menu = [CCMenu menuWithItems:
				//title1, title2,
				//item1, item2,
				highres, highres2,
				title3, //title4,
				item3, //item4,
				reset,
				back, nil]; // 9 items.
		[menu alignItemsInColumns:
		 [NSNumber numberWithUnsignedInt:1],
		 [NSNumber numberWithUnsignedInt:1],
		 [NSNumber numberWithUnsignedInt:1],
		 [NSNumber numberWithUnsignedInt:1],
		 [NSNumber numberWithUnsignedInt:1],
		 [NSNumber numberWithUnsignedInt:1],
		 nil]; 
	} else {
		menu = [CCMenu menuWithItems:
				//title1, title2,
				//item1, item2,
				highres, highres2,
				//title3, //title4,
				//item3, //item4,
				reset,
				back, nil]; // 9 items.
		[menu alignItemsInColumns:
		 
		 //[NSNumber numberWithUnsignedInt:1],
		 [NSNumber numberWithUnsignedInt:1],
		 [NSNumber numberWithUnsignedInt:1],
		 [NSNumber numberWithUnsignedInt:1],
		 [NSNumber numberWithUnsignedInt:1],
		 nil]; 
	}
    
	[self addChild: menu];
		
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) highResCallback:(id) sender{
	
	//DrawBattlefieldAppDelegate *appDelegate = (DrawBattlefieldAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	int select = [sender selectedIndex];
	
	CCDirector *director = [CCDirector sharedDirector];
	
	CGRect window = [[UIScreen mainScreen] bounds];
	
	if (select == 0) {
		[director setContentScaleFactor:2];
		[director reshapeProjection:CGSizeMake(320,320)];
		//[director reshapeProjection:CGSizeMake(window.size.width,window.size.height)];
	} else if (select == 1) {
		[director setContentScaleFactor:1];
		[director reshapeProjection:CGSizeMake(320,320)];
		//[director reshapeProjection:CGSizeMake(window.size.width,window.size.height)];

	}
	//[[NSUserDefaults standardUserDefaults] setBool:appDelegate.vibrateOptionOff forKey:@"vibrateOptionOff"];
}

-(void) vibrateCallback:(id) sender{
	
	DrawBattlefieldAppDelegate *appDelegate = (DrawBattlefieldAppDelegate *)[[UIApplication sharedApplication] delegate];

	int select = [sender selectedIndex];
	
	if (select == 0) {
		appDelegate.vibrateOptionOff = NO;
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	} else if (select == 1) {
		appDelegate.vibrateOptionOff = YES;
	}
	[[NSUserDefaults standardUserDefaults] setBool:appDelegate.vibrateOptionOff forKey:@"vibrateOptionOff"];
}

-(void) menuCallback: (id) sender{
	
	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
}

-(void) backCallback: (id) sender{
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInT transitionWithDuration:1 scene:[MainMenuLayer node]]];
}


-(void) resetSavedDataCallback: (id) sender{
	
	[[NSFileManager defaultManager] removeItemAtPath:[Battleground defaultSavedDataFile] error:NULL];

	[NSUserDefaults resetStandardUserDefaults];
	
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"vibrateOptionOff"];

}

@end
