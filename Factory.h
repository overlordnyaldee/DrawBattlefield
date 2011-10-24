//
//  Factory.h
//  DrawBattlefield
//
//  Created by James Washburn on 9/29/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Extends Unit to add factory functionality

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "factions.h"
#import "Unit.h"

@interface Factory : Unit {
	int productionRate;
	int productionUnit;
}

@property (nonatomic, readwrite, assign) int productionRate;
@property (nonatomic, readwrite, assign) int productionUnit;

+ (Factory *) factoryWithSize:(int) size withPosition:(CGPoint)position;

+ (Factory *) factoryFromData:(NSMutableDictionary *)savedData;

- (Unit *) createUnitFromProduction;

- (NSMutableDictionary *) saveableData;

@end
