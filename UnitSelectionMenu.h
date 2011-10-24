//
//  UnitSelectionMenu.h
//  DrawBattlefield
//
//  Created by James Washburn on 5/19/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Selection menu for units to add to a battleground

//#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "factions.h"

@interface UnitSelectionMenu : CCLayer {
	int faction;
	BOOL wasFighting;
	CCMenu *menu;
	CCColorLayer *backgroundLayer;
}

@property (nonatomic, readwrite, assign) int faction;
@property (nonatomic, readwrite, assign) BOOL wasFighting;
@property (nonatomic, readwrite, retain) CCMenu *menu;
@property (nonatomic, readwrite, retain) CCColorLayer *backgroundLayer;


-(void)addSoldier:(id) sender;
-(void)addSoldierp:(id) sender;
-(void)addSoldiera:(id) sender;
-(void)addTank:(id) sender;
-(void)addTankp:(id) sender;
-(void)addTurretl:(id) sender;
-(void)addTurreth:(id) sender;

-(void)closeUnitSelection:(id) sender;

-(void)changeFaction:(id) sender;

- (CGPoint) center;

@end
