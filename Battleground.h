//
//  Battleground.h
//  DrawBattlefield
//
//  Created by James Washburn on 5/18/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Battleground game class

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"

@class UnitControl;
@class Unit;

#define GRABABLE_MASK_BIT (1<<31)
#define NOT_GRABABLE_MASK (~GRABABLE_MASK_BIT)

@interface Battleground : CCLayer <CCStandardTouchDelegate> {
	
	int typeOfBattleground;
	
	UnitControl *unitSystem;
	
	Unit *selectedUnit;
	
	CGPoint previousTouch;
	CGPoint previousTouch2;
	
	CGPoint offsetUnits;
	
	CCColorLayer *backgroundLayer;
	CCMenu *menu;
	
	BOOL isFighting;
	BOOL wasFighting;
	BOOL vibrateOptionOff;
	BOOL shouldDisplayMovementBox;
	
	NSString *challengeAchievementID;
	
	long kills;
	
}

@property (nonatomic, readwrite, assign) int typeOfBattleground;

@property (nonatomic, readwrite, retain) UnitControl *unitSystem;

@property (nonatomic, readwrite, retain) Unit *selectedUnit;

@property (nonatomic, readwrite, assign) CGPoint previousTouch;
@property (nonatomic, readwrite, assign) CGPoint previousTouch2;

@property (nonatomic, readwrite, assign) CGPoint offsetUnits;

@property (nonatomic, readwrite, retain) CCColorLayer *backgroundLayer;
@property (nonatomic, readwrite, retain) CCMenu *menu;

@property (nonatomic, readwrite, assign) BOOL isFighting;
@property (nonatomic, readwrite, assign) BOOL wasFighting;
@property (nonatomic, readwrite, assign) BOOL vibrateOptionOff;
@property (nonatomic, readwrite, assign) BOOL shouldDisplayMovementBox;

@property (nonatomic, readwrite, retain) NSString *challengeAchievementID;

@property (nonatomic, readwrite, assign) long kills;


+ (id) battleground;

+ (id) battlegroundWithSavedBattleground:(NSString *)file;

+ (id) battlegroundWithSavedChallenge:(NSString *)challengeType;

+ (id) mainMenuBackground;

- (void) orientationChanged:(NSNotification *)notification;

- (void) spawnRandomUnits;

- (void) addUnitWithType:(int) unitType;

- (void) addUnitWithType:(int) unitType faction:(int)faction;

- (void) addUnitWithinCurrentViewWithType:(int) unitType faction:(int)faction;

- (void) addUnitWithType:(int) unitType faction:(int)faction withinCurrentView:(BOOL)isCurrentView;

- (void) clearUnitsOnField: (id) sender;

- (void) fightBattle;

- (void) createExplosionWithPosition:(CGPoint) position;

- (BOOL) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

+ (NSString *) defaultSavedDataFile;

+ (NSString *) savedDataFileWithName:(NSString *) name;

- (BOOL) saveBattlegroundToFile:(NSString *)file;

- (BOOL) readBattlegroundFromFile:(NSString *)file;

- (void) toggleBattle;

- (void) pauseBattle;

- (void) resumeBattle;

//@end

//@interface Battleground (private)

- (void) initChipmunk;
- (void) step: (ccTime)delta;
- (void) checkEmptyFaction;
- (void) setupMenu;
- (void) loadDashboard: (id) sender;
- (void) showMenu;
- (void) hideMenu;
- (void) toggleMenu: (id)data;

- (void) adjustPosition:(id)node;
- (void) removeBullet: (id)node;
- (void) removeEffect: (id)node;

- (void) saveKillCountFromSession;
- (void) checkKillCountAchievement;

- (CGPoint) center;

- (void) cleanAllBullets;

- (void) returnToMain: (id)sender;

@end



