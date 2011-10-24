//
//  UnitManagementLayer.h
//  DrawBattlefield
//
//  Created by James Washburn on 9/28/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Displays unit statistics for the user

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "factions.h"

@class Unit;

@interface UnitManagementLayer : CCLayer {
	
	CCMenu *menu;
	
	Unit *displayUnit;
	
	CCLabelTTF *displayHP;
	CCLabelTTF *displayAttack;
	CCLabelTTF *displayArmor;
	CCLabelTTF *displayRange;
	
	CCSprite *sidebar;
	
}

@property (nonatomic, readwrite, retain) CCMenu *menu;

@property (nonatomic, readwrite, retain) Unit *displayUnit;

@property (nonatomic, readwrite, retain) CCLabelTTF *displayHP;
@property (nonatomic, readwrite, retain) CCLabelTTF *displayAttack;
@property (nonatomic, readwrite, retain) CCLabelTTF *displayArmor;
@property (nonatomic, readwrite, retain) CCLabelTTF *displayRange;

@property (nonatomic, readwrite, retain) CCSprite *sidebar;

- (void) updateUnitStatistics;

@end
