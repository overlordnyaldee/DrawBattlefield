//
//  Unit.h
//  DrawBattlefield
//
//  Created by James Washburn on 9/9/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Extends CocosNode with unit specific functions

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "factions.h"

@class UnitControl;
@class Battleground;

@interface Unit : CCSprite {
	int faction;
	cpBody *body;
	cpShape *shape1;

	int unitType;
	
	cpFloat currentHitPoints;
	cpFloat maxHitPoints;
	NSUInteger attack;
	NSUInteger armor;
	NSUInteger range;
	NSUInteger cost;
	CGPoint bulletOffset;
	
	UnitControl *unitSystem;
}

@property (nonatomic, readwrite, assign) int faction;
@property (nonatomic, readwrite, assign) cpBody *body;
@property (nonatomic, readwrite, assign) int unitType;
@property (nonatomic, readwrite, assign) cpShape *shape1;

@property (nonatomic, readwrite, assign) cpFloat currentHitPoints;
@property (nonatomic, readwrite, assign) cpFloat maxHitPoints;
@property (nonatomic, readwrite, assign) NSUInteger attack;
@property (nonatomic, readwrite, assign) NSUInteger armor;
@property (nonatomic, readwrite, assign) NSUInteger range;
@property (nonatomic, readwrite, assign) NSUInteger cost;
@property (nonatomic, readwrite, assign) CGPoint bulletOffset;
@property (nonatomic, readwrite, assign) UnitControl *unitSystem;

+ (Unit *) unitWithType:(int)type withFaction:(int)newFaction withPosition:(CGPoint)position;
+ (Unit *) unitWithType:(int)type withFaction:(int)newFaction;

+ (Unit *) unitWithType:(int)type withFaction:(int)newFaction withinCurrentView:(BOOL) isCurrentView;
+ (Unit *) unitWithinCurrentViewWithType:(int)type withFaction:(int)newFaction;

+ (Unit *) unitFromData:(NSMutableDictionary *)savedData;

+ (NSString *) stringFromUnitType:(int) type;
+ (NSString *) stringHumanReadableFromUnitType:(int) type ;

- (void) damageByAmount:(double)damage;

- (void) updateUnitHealthDisplay;

- (int) getHealthColor;

- (void) dealloc;

- (id)  spriteWithTexture:(CCTexture2D*) tex;

- (NSMutableDictionary *) saveableData;

@end
