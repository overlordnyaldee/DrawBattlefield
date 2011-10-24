//
//  MainMenuLayer.m
//  DrawBattlefield
//
//  Created by James Washburn on 5/13/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import "MainMenuLayer.h"

#import "OpenFeint.h"
#import "Battleground.h"
#import "OptionsMenu.h"
#import "UnitManagementLayer.h"
#import "factions.h"

@implementation MainMenuLayer

@synthesize battleground;
@synthesize background;
@synthesize menu;
@synthesize challengeMenu;
//@synthesize picker;
//@synthesize session;


-(id) init{
	[super init];
	if ((self = [super init])) {
		// Seed the random number generator
		srand((cpFloat)[[NSDate date] timeIntervalSince1970]);
				
		self.background = [CCColorLayer layerWithColor: ccc4(200, 200, 200, 255)];
		[self addChild: self.background z:-1 tag:9001];
		
		// Main menu setup
		[CCMenuItemFont setFontSize:64];
		[CCMenuItemFont setFontName:@"Marker Felt"];
#ifndef LITE_BUILD
		CCMenuItemFont *titleItem = [CCMenuItemFont itemFromString: @"DrawBattlefield" target:self selector:@selector(onPushScene:)];
#else
		[CCMenuItemFont setFontSize:58];
		CCMenuItemFont *titleItem = [CCMenuItemFont itemFromString: @"DrawBattlefield Lite" target:self selector:@selector(onPushScene:)];
#endif
		[titleItem setIsEnabled:NO];
		[[titleItem label] setColor:ccc3(0, 0, 0)];
		
		//[MenuItemFont setFontName:@"Helvetica"];
		
		[CCMenuItemFont setFontSize:32];
		//MenuItemFont *newGameItem = [MenuItemFont itemFromString: @"New Game" target:self selector:@selector(loadBattlegroundSceneAuto:)];
		CCMenuItemFont *challengesItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Challenge Mode", nil) target:self selector:@selector(loadChallengeMenu:)];
		CCMenuItemFont *continueItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Continue", nil) target:self selector:@selector(onPushSceneTran:)];
		CCMenuItemFont *freeModeItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Free Mode", nil) target:self selector:@selector(loadBattlegroundScene:)];
		//MenuItemFont *multiplayerItem = [MenuItemFont itemFromString: @"Multiplayer" target:self selector:@selector(loadMultiplayer:)];
		CCMenuItemFont *unitManagementItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Unit Management", nil) target:self selector:@selector(loadUnitManagement:)];
		//MenuItemFont *openFeintItem = [MenuItemFont itemFromString: @"OpenFeint Dashboard" target:self selector:@selector(loadDashboard:)];
		CCMenuItemFont *optionsItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Options", nil) target:self selector:@selector(loadOptionsMenu:)];
		
		/*Sprite *OFButton = [Sprite spriteWithTexture:[[TextureMgr sharedTextureMgr] addImage:@"button_140x40.png"]];
		
		MenuItemSprite *OFitem = [MenuItemSprite itemFromNormalSprite:OFButton 
													   selectedSprite:OFButton 
															   target:self 
															 selector:@selector(loadDashboard:)];*/
		
		self.menu = [CCMenu menuWithItems: 
					 titleItem, 
					 challengesItem,
					 //newGameItem, 
					 continueItem, 
					 freeModeItem, 
					 //multiplayerItem, 
					 unitManagementItem,
					 //openFeintItem,
					 optionsItem,
					 //OFitem,
					 nil];
		
#ifdef LITE_BUILD
		[menu removeChild:freeModeItem cleanup:YES];
#endif

		[menu alignItemsVerticallyWithPadding:2];
		[self addChild: self.menu z:INT_MAX];
		
		//MenuItemFont *challengeItem = [MenuItemFont itemFromString: @"Challenges:" target:self selector:nil];
		CCMenuItemFont *challengeItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Challenges:", nil) target:self selector:nil];
		[challengeItem setIsEnabled:NO];
		[[challengeItem label] setColor:ccc3(0, 0, 0)];
		CCMenuItemFont *sniperChallengeItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Sniper Challenge", nil) target:self selector:@selector(loadSniperChallenge:)];
		CCMenuItemFont *armoredChallengeItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Armored Challenge", nil) target:self selector:@selector(loadArmoredChallenge:)];
		CCMenuItemFont *turretChallengeItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Turret Challenge", nil) target:self selector:@selector(loadTurretChallenge:)];
		CCMenuItemFont *tank1ChallengeItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Tank Challenge One", nil) target:self selector:@selector(loadTank1Challenge:)];
		CCMenuItemFont *tank2ChallengeItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Tank Challenge Two", nil) target:self selector:@selector(loadTank2Challenge:)];
		CCMenuItemFont *returnItem = [CCMenuItemFont itemFromString: NSLocalizedString(@"Return", nil) target:self selector:@selector(returnToMainMenu:)];
		
		
		
		self.challengeMenu = [CCMenu menuWithItems: 
							  //titleItem, 
							  challengeItem,
							  sniperChallengeItem,
							  armoredChallengeItem, 
							  turretChallengeItem,
							  tank1ChallengeItem, 
							  tank2ChallengeItem,
							  returnItem, 
							  nil];
		[challengeMenu alignItemsVertically];
		
		self.battleground = [Battleground mainMenuBackground];
		[self addChild:self.battleground];
		
		// OpenFeint dashboard icon init
		CCSprite *openFeintSprite = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"openfeintmenu1.png"]];	

		CCMenuItemSprite *openFeintMenuItem = [CCMenuItemSprite itemFromNormalSprite:openFeintSprite 
															 selectedSprite:openFeintSprite 
																	 target:self 
																	selector:@selector(loadDashboard:)];
		[openFeintMenuItem setScale:0.25f];
		
		CCMenu *menuOpenFeint = [CCMenu menuWithItems:openFeintMenuItem, nil];
		[menuOpenFeint setPosition:cpv(34, 30)];
		[self addChild:menuOpenFeint];
		
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(orientationChanged:) 
													 name:@"UIDeviceOrientationDidChangeNotification" 
												   object:nil];
		
		/*picker = [[GKPeerPickerController alloc] init];
		picker.delegate = self;
		picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby | GKPeerPickerConnectionTypeOnline;*/
	}
	return self;
}

- (void) orientationChanged:(NSNotification *)notification {
	
	[self.menu setPosition:[self center]];
	[self.challengeMenu setPosition:[self center]];
	[self.background setContentSize:[[CCDirector sharedDirector] winSize]];
	
}

-(void) onExit{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super onExit];
	
}

-(void) dealloc{
	
	[self removeAllChildrenWithCleanup:YES];
	
	[battleground release];
		
	//[picker release];
	//[session release];
	
	[myData release];
	
	[background release];
	[menu release];
	[challengeMenu release];
	
	[super dealloc];
}

-(void) loadDashboard: (id) sender{
	
	/*UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if ((orientation ==  UIDeviceOrientationLandscapeLeft) || (orientation ==  UIDeviceOrientationLandscapeRight)) {
		[OpenFeint setDashboardOrientation:(UIInterfaceOrientation)[[UIDevice currentDevice] orientation]];
	}*/
	
	[OpenFeint launchDashboard];
	
}

-(void) loadChallengeMenu: (id) sender{
	[self removeChild:self.menu cleanup:YES];
	[[battleground getChildByTag:90101] runAction:[CCTintTo actionWithDuration:0.25f red:150 green:150 blue:150]];
	[self addChild: self.challengeMenu z:INT_MAX];
	
}

-(void) returnToMainMenu: (id) sender{
	[self removeChild:self.challengeMenu cleanup:YES];
	[[battleground getChildByTag:90101] runAction:[CCTintTo actionWithDuration:0.25f red:200 green:200 blue:200]];
	[self addChild: self.menu z:INT_MAX];
}

-(void) loadSniperChallenge: (id) sender{
	//[battleground pauseBattle];
	//[battleground cleanAllBullets];
	[self removeChild:battleground cleanup:YES];
	[[CCDirector sharedDirector] replaceScene: 
	 [CCTransitionSlideInT transitionWithDuration:1 scene:
	  [Battleground battlegroundWithSavedChallenge:kBattlegroundChallengeTypeSniper]]];
}
-(void) loadArmoredChallenge: (id) sender{
	//[battleground pauseBattle];
	//[battleground cleanAllBullets];
	[self removeChild:battleground cleanup:YES];
	[[CCDirector sharedDirector] replaceScene: 
	 [CCTransitionSlideInT transitionWithDuration:1 scene:
	  [Battleground battlegroundWithSavedChallenge:kBattlegroundChallengeTypeArmored]]];
}
-(void) loadTurretChallenge: (id) sender{
	//[battleground pauseBattle];
	//[battleground cleanAllBullets];
	[self removeChild:battleground cleanup:YES];
	[[CCDirector sharedDirector] replaceScene: 
	 [CCTransitionSlideInT transitionWithDuration:1 scene:
	  [Battleground battlegroundWithSavedChallenge:kBattlegroundChallengeTypeTurret]]];
}
-(void) loadTank1Challenge: (id) sender{
	//[battleground pauseBattle];
	//[battleground cleanAllBullets];
	[self removeChild:battleground cleanup:YES];
	[[CCDirector sharedDirector] replaceScene: 
	 [CCTransitionSlideInT transitionWithDuration:1 scene:
	  [Battleground battlegroundWithSavedChallenge:kBattlegroundChallengeTypeTank1]]];
}
-(void) loadTank2Challenge: (id) sender{
	//[battleground pauseBattle];
	//[battleground cleanAllBullets];
	[self removeChild:battleground cleanup:YES];
	[[CCDirector sharedDirector] replaceScene: 
	 [CCTransitionSlideInT transitionWithDuration:1 scene:
	  [Battleground battlegroundWithSavedChallenge:kBattlegroundChallengeTypeTank2]]];
}

-(void) loadBattlegroundScene: (id) sender{
	//[battleground pauseBattle];
	//[battleground cleanAllBullets];
	[self removeChild:battleground cleanup:YES];
	[[CCDirector sharedDirector] replaceScene: 
	 [CCTransitionSlideInR transitionWithDuration:1 scene:[Battleground battleground]]];
}

-(void) onPushSceneTran: (id) sender{
	//[battleground pauseBattle];
	//[battleground cleanAllBullets];
	[self removeChild:battleground cleanup:YES];
	[[CCDirector sharedDirector] replaceScene: 
	 [CCTransitionSlideInR transitionWithDuration:1 scene:[Battleground battlegroundWithSavedBattleground:nil]]];
}

-(void) loadOptionsMenu: (id) sender{
	//[battleground pauseBattle];
	//[battleground cleanAllBullets];
	[self removeChild:battleground cleanup:YES];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInB transitionWithDuration:1 scene:[OptionsMenu node]]];
}

/*-(void) loadMultiplayer: (id) sender{
	//[picker show];
}*/

-(void) loadUnitManagement: (id) sender{
	//[battleground pauseBattle];
	//[battleground cleanAllBullets];
	[self removeChild:battleground cleanup:YES];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInL transitionWithDuration:1 scene:[UnitManagementLayer node]]];
}

-(void) onPushScene: (id) sender{
	//Scene * scene = [[Scene node] addChild: [Layer2 node] z:0];
	//[[Director sharedDirector] pushScene: scene];
}
			 
- (CGPoint) center {
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	return CGPointMake(winSize.width/2, winSize.height/2);
	
}
			 
/*
- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type {
	if(type == GKPeerPickerConnectionTypeOnline) {
		[self.picker dismiss];
		//[self.picker release];
		//self.picker = nil;
		// Display your own UI here.
	}
}


- (GKSession *) peerPickerController:(GKPeerPickerController *)picker
			sessionForConnectionType:(GKPeerPickerConnectionType)type {
	session = [[GKSession alloc] initWithSessionID:@"FR" displayName:nil sessionMode:GKSessionModePeer];
	session.delegate = self;
	
	return session;
}


- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	switch (state) {
		case GKPeerStateConnected:
			[self.session setDataReceiveHandler :self withContext:nil];
			[self mySendData]; // start off by sending data upon connection
			break;
			
		case GKPeerStateDisconnected:
			break;
	}
}


- (void)peerPickerController:(GKPeerPickerController *)picker didConnectToPeer:(NSString *)peerID {
	printf("connection was successful! start the game.\n");
}


- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
	printf("connection attempt was canceled\n");
}

- (void)mySendData {
	// allocate the NSData
	myNumber++;
	myData = [[NSData alloc] initWithBytes:&myNumber length:sizeof(int)];
	[session sendDataToAllPeers :myData withDataMode:GKSendDataReliable error:nil];
	printf("send data: %i\n", myNumber);
	//textView.text = [NSString stringWithFormat:@"myNumber: %i\n", myNumber];
}


- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	// Read the bytes in data and perform an application-specific action, then free the NSData object
	[data getBytes:&myNumber length:sizeof(int)];
	printf("received data: %i from: %s\n", myNumber, [peer UTF8String]);
	//textView.text = [NSString stringWithFormat:@"myNumber: %i\n", myNumber];
	
	[self mySendData];
}
*/

@end