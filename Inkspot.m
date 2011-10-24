//
//  Inkspot.m
//  DrawBattlefield
//
//  Created by James Washburn on 9/30/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import "Inkspot.h"

@implementation Inkspot

extern cpSpace *space;

+ (Inkspot *) inkspotWithPosition:(CGPoint)position{
	
	Inkspot *inkSpot = [super spriteWithTexture:[[CCTextureCache sharedTextureCache] 
												 addPVRTCImage:@"inkspot.pvrtc" 
												 bpp:4 
												 hasAlpha:YES 
												 width:64]];
	
	[inkSpot retain];
	
	inkSpot.faction = kFactionNeutral;
	inkSpot.unitType = kUnitTypeInkspot;
	inkSpot.currentHitPoints = 0;
	inkSpot.maxHitPoints = 0;
	inkSpot.attack = 0;
	inkSpot.armor = 0;
	inkSpot.range = 0;
	inkSpot.cost = 0;
	
	// Add collision body
	//inkSpot.body = cpBodyNew(100.0f, cpMomentForCircle(, 80, 80, CGPointZero));
	inkSpot.body = cpBodyNew(INFINITY, INFINITY);
	//Set rotation
	double rot = ((double)rand() / ((double)RAND_MAX + 1) * 360); 
	cpBodySetAngle(inkSpot.body, (float)CC_DEGREES_TO_RADIANS(-rot) );
	//[newUnit setRotation: (float)rot];
	
	cpSpaceAddBody(space, inkSpot.body);
	//cpSpacea
	
	inkSpot.body->data = inkSpot;
	
	cpShape *shape = cpCircleShapeNew(inkSpot.body, 20, CGPointZero);
	
	// Add collision shape
	shape->e = 0.1f; shape->u = 3.0f;
	shape->data = inkSpot;
	cpSpaceAddShape(space, shape);
	//cpSpaceAddStaticShape(space, shape);
	inkSpot.shape1 = shape;
	
	
	[inkSpot autorelease];
	
	inkSpot.position = position;
	
	cpBodySetPos(inkSpot.body, position);

	cpSpaceRehashStatic(space);

	
	return inkSpot;
	
}

+ (Inkspot *) inkspotFromData:(NSMutableDictionary *)savedData {
	
	if (savedData) {
		
		//int typeSaved = [[savedData objectForKey:@"type"] intValue];
		//int factionSaved = [[savedData objectForKey:@"faction"] intValue];
		
		cpFloat currentHPSaved = [[savedData objectForKey:@"currenthp"] floatValue];
		cpFloat positionXSaved = [[savedData objectForKey:@"positionx"] floatValue];
		cpFloat positionYSaved = [[savedData objectForKey:@"positiony"] floatValue];
		cpFloat rotationSaved = [[savedData objectForKey:@"rotation"] floatValue];
		
		Inkspot *inkspotSaved = [self inkspotWithPosition:CGPointMake(positionXSaved, positionYSaved)];
		//[self unitWithType:typeSaved withFaction:factionSaved withPosition:CGPointMake(positionXSaved, positionYSaved)];
		
		if (inkspotSaved) {
			
			inkspotSaved.currentHitPoints = currentHPSaved;
			cpBodySetPos(inkspotSaved.body, CGPointMake(positionXSaved, positionYSaved));
			inkspotSaved.position = CGPointMake(positionXSaved, positionYSaved);
			cpBodySetAngle(inkspotSaved.body, (float)CC_DEGREES_TO_RADIANS(-rotationSaved) );
			inkspotSaved.rotation = rotationSaved;
			[inkspotSaved stopAllActions];
			[inkspotSaved updateUnitHealthDisplay];
			
#ifdef DEBUG
			NSLog(@"unit restored");
#endif

			return inkspotSaved;
		}
		
#ifdef DEBUG
		NSLog(@"unit corrupt");
#endif

		return nil;
		
	}
	
#ifdef DEBUG
	NSLog(@"unit corrupt");
#endif
	
	return nil;
}

- (void) dealloc {
	
	if (body && space) {
		cpSpaceRemoveBody(space, self.body);
		cpBodyFree(self.body);
		self.body = nil;
	}
	
	if (shape1 && space) {
		cpSpaceRemoveShape(space, self.shape1);
		cpShapeFree(self.shape1);
		self.shape1 = nil;
	}
	
	[super dealloc];
	
}


@end
