//
//  Bullet.m
//  DrawBattlefield
//
//  Created by James Washburn on 9/27/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import "Bullet.h"


@implementation Bullet

@synthesize damage;
@synthesize bulletShape;
@synthesize bulletBody;
@synthesize unitShotFrom;

extern cpSpace *space;

+ (Bullet *) bulletWithFile:(NSString *)file withUnitAttacking:(Unit *)unit{
	
	Bullet *bullet = [super spriteWithTexture:[[CCTextureCache sharedTextureCache] addPVRTCImage:file bpp:4 hasAlpha:YES width:32]];
	
	bullet.unitShotFrom = unit;

	bullet.damage = 0;
	
	return bullet;
}

+ (Bullet *) bulletwithScale:(float)scale withUnitAttacking:(Unit *)unitAttacking toUnitDefending:(Unit *)unitDefending{
	
	Bullet *bullet = [super spriteWithTexture:[[CCTextureCache sharedTextureCache] addPVRTCImage:@"bullettype1.pvrtc" bpp:4 hasAlpha:YES width:32]];
	
	bullet.unitShotFrom = unitAttacking;
	bullet.damage = unitAttacking.attack; 
	
	if (unitAttacking.unitType == kUnitTypeSoldierRocket) {
		[bullet setScale: scale * 1.5f];
	} else {
		[bullet setScale: scale];
	}
	
	cpBody *bulletBody = cpBodyNew(10.0f, cpMomentForCircle(10.0f, 3 * scale, 3 * scale, CGPointZero));
	cpSpaceAddBody(space, bulletBody);
	
	cpShape *bulletShape = cpCircleShapeNew(bulletBody, 3 * scale, CGPointZero);
	
	// Add collision shape
	bulletShape->e = 0.1f; bulletShape->u = 3.0f;
	bulletShape->data = bullet;
	bulletShape->collision_type = kCollisionTypeBullet;
	cpSpaceAddShape(space, bulletShape);
	
	cpBodySetPos(bulletBody, unitAttacking.position);
	[bullet setPosition: unitAttacking.position];
	
	bullet.bulletShape = bulletShape;
	bullet.bulletBody = bulletBody;
	
	return bullet;
}

- (void) cleanup {
	
	if (bulletBody) {
		if (cpArrayContains(space->bodies, bulletBody)) {
			cpSpaceRemoveBody(space, self.bulletBody);
			cpBodyFree(self.bulletBody);
		}
		self.bulletBody = nil;
	}
	
	if (bulletShape) {
		if (cpHashSetFind(space->activeShapes->handleSet, bulletShape->hashid, bulletShape)) {
			cpSpaceRemoveShape(space, self.bulletShape);
			cpShapeFree(self.bulletShape);
		}
		self.bulletShape = nil;
	}
	
	[super cleanup];
}

- (void) dealloc {
	
	[unitShotFrom release];
	
	[super dealloc];
	
}

@end
