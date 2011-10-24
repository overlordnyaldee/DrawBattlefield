//
//  UnitControl.h
//  DrawBattlefield
//
//  Created by James Washburn on 9/9/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "factions.h"

@class Battleground;
@class Unit;
@class Factory;
@class Inkspot;

@interface UnitControl : NSObject {
	Battleground *parent;
	ccArray *unitArray;
	ccArray *factoryArray;
	ccArray *inkspotArray;

	float unitScale;
	int unitsFriendly;
	int unitsEnemy;
	
	int factoriesFriendly;
	int factoriesEnemy;
	Unit *unitToRemove_;
}

@property (nonatomic, readwrite, assign) Battleground *parent;

@property (nonatomic, readwrite, assign) ccArray *unitArray;
@property (nonatomic, readwrite, assign) ccArray *factoryArray;
@property (nonatomic, readwrite, assign) ccArray *inkspotArray;

@property (nonatomic, readwrite, assign) float unitScale;

@property (nonatomic, readonly, assign) int unitCount;
@property (nonatomic, readonly, assign) int factoryCount;
@property (nonatomic, readonly, assign) int inkspotCount;

@property (nonatomic, readwrite, assign) int unitsFriendly;
@property (nonatomic, readwrite, assign) int unitsEnemy;

@property (nonatomic, readwrite, assign) int factoriesFriendly;
@property (nonatomic, readwrite, assign) int factoriesEnemy;

@property (nonatomic, readwrite, assign) Unit *unitToRemove_;


+ (UnitControl *) unitControl;

- (void) addUnit:(Unit *)unit;
- (void) addUnit:(Unit *)unit withPosition:(CGPoint)position;

- (void) removeUnit:(Unit *)unitToRemove;
- (void) removeUnit:(Unit *)unitToRemove withConfirm:(BOOL)confirm;

- (Unit *) randomUnit;

- (Unit *) randomUnitFromFaction:(int)faction;

- (Unit *) unitAtPosition:(CGPoint)position;
- (Unit *) unitAtPosition:(CGPoint)position withinPixels:(cpFloat)variance;
- (Unit *) unitAtPosition:(CGPoint)position withinRange:(cpFloat)variance withFaction:(int)faction;


- (BOOL) isAnyFactionEmpty;

- (void) moveAllUnitsWithDifference:(CGPoint)position;

- (void) moveAllUnitsToPosition:(CGPoint)position;

- (void) zoomInAllUnitsFromPosition:(CGPoint)position;

- (void) zoomOutAllUnitsFromPosition:(CGPoint)position;

- (void) healAllUnits;

- (void) freezeAllUnits;

- (void) clearAllUnits;

- (void) updateHealthDisplayOfAllUnits;

+ (int) opposingFactionOfFaction:(int)faction;

+ (int) randomFaction;

- (void) addFactory:(Factory *)factoryToAdd;
- (void) addFactory:(id)factory withPosition:(CGPoint)position;
- (void) removeFactory:(id)factory;

- (void) addInkspot:(Inkspot *)inkspotToAdd;
- (void) addInkspot:(Inkspot *)inkspotToAdd withPosition:(CGPoint)position;
- (void) removeInkspot:(Inkspot *)inkspotToRemove;

- (NSMutableArray *) saveableDataForAllUnits;

- (void) restoreUnitsFromSavedData:(NSMutableArray *)data;


@end
