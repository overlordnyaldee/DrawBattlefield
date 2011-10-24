//
//  MainMenuLayer.h
//  DrawBattlefield
//
//  Created by James Washburn on 5/13/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Main menu, display, and challenges menu

#import <Foundation/Foundation.h>
#import "cocos2d.h"
//#import <GameKit/GameKit.h>

@class Battleground;

@interface MainMenuLayer : CCLayer //<GKPeerPickerControllerDelegate, GKSessionDelegate>
{
	
	Battleground *battleground;
	
	//GKPeerPickerController *picker;
	//GKSession *session;
	
	int myNumber;
	NSData *myData;
	
	CCColorLayer *background;
	CCMenu *menu;
	CCMenu *challengeMenu;
}

@property (nonatomic, readwrite, retain) Battleground *battleground;

@property (nonatomic, readwrite, retain) CCColorLayer *background;
@property (nonatomic, readwrite, retain) CCMenu *menu;
@property (nonatomic, readwrite, retain) CCMenu *challengeMenu;

-(void) loadBattlegroundScene: (id) sender;
-(void) loadOptionsMenu: (id) sender;
-(void) onPushScene: (id) sender;
-(void) onPushSceneTran: (id) sender;
- (CGPoint) center;

//- (void)mySendData;

//@property (nonatomic, retain) GKPeerPickerController *picker;
//@property (nonatomic, retain) GKSession *session;

@end