//
//  Bullet.h
//  DrawBattlefield
//
//  Created by James Washburn on 9/27/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Bullet object, contains physics objects and damage amount

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Unit.h"
#import "factions.h"

//#import "factions.h"

@interface Bullet : CCSprite {
	int damage;
	cpShape *bulletShape;
	cpBody *bulletBody;
	Unit *unitShotFrom;
}

@property (nonatomic, readwrite, assign) int damage;
@property (nonatomic, readwrite, assign) cpShape *bulletShape;
@property (nonatomic, readwrite, assign) cpBody *bulletBody;
@property (nonatomic, readwrite, retain) Unit *unitShotFrom;

+ (Bullet *) bulletWithFile:(NSString *)file withUnitAttacking:(Unit *)unit;

+ (Bullet *) bulletwithScale:(float)scale withUnitAttacking:(Unit *)unitAttacking toUnitDefending:(Unit *)unitDefending;

@end
