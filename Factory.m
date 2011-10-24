//
//  Factory.m
//  DrawBattlefield
//
//  Created by James Washburn on 9/29/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import "Factory.h"

@implementation Factory

@synthesize productionRate;
@synthesize productionUnit;

extern cpSpace *space;

- (id)init {
    if ((self = [super init])) {
		
		self.faction = kFactionNeutral;
		self.body = nil;
		self.unitType = kUnitTypeFactory;
		self.shape1 = nil;
		self.currentHitPoints = 100;
		self.maxHitPoints = 100;
		self.attack = 0;
		self.armor = 2;
		self.range = 0;
		self.cost = 0;
		
		self.productionRate = 0;
		self.productionUnit = 0;
		self.unitType = kUnitTypeFactory;
		
		
		
	}
	
    return self;
	
}

+ (Factory *) factoryWithSize:(int) size withPosition:(CGPoint)position {
	
	//Factory *factory = [[self alloc] init];
	
	
	Factory *factory = nil;
	
	int unitSize = 20;
	
	if (size == kFactorySizeSmall) {
		factory = [super spriteWithTexture:[[CCTextureCache sharedTextureCache] 
											 addPVRTCImage:@"factorysmall.pvrtc" 
											 bpp:4 
											 hasAlpha:YES 
											 width:128]];
		[factory setScale:0.4f];

	} else if (size == kFactorySizeMedium) {
		factory = [super spriteWithTexture:[[CCTextureCache sharedTextureCache] 
											addPVRTCImage:@"factorymedium.pvrtc" 
											bpp:4 
											hasAlpha:YES 
											width:128]];
		[factory setScale:0.5f];

	} else if (size == kFactorySizeLarge) {
		factory = [super spriteWithTexture:[[CCTextureCache sharedTextureCache] 
											addPVRTCImage:@"factorylarge.pvrtc" 
											bpp:4 
											hasAlpha:YES 
											width:128]];
		[factory setScale:0.6f];
		unitSize = 40;

	} else {
		return nil;
	}

	factory.faction = kFactionNeutral;
	factory.unitType = kUnitTypeInkspot;
	factory.currentHitPoints = 0;
	factory.maxHitPoints = 0;
	factory.attack = 0;
	factory.armor = 0;
	factory.range = 0;
	factory.cost = 0;
	
	factory.productionRate = size;
	factory.productionUnit = -1;
	factory.unitType = kUnitTypeFactory;
	
	// Add collision body
	//factory.body = cpBodyNew(100.0f, cpMomentForCircle(100.0f, 80, 80, CGPointZero));
	factory.body = cpBodyNew(INFINITY, INFINITY);

	//Set rotation
	double rot = ((double)rand() / ((double)RAND_MAX + 1) * 360); 
	cpBodySetAngle(factory.body, (float)CC_DEGREES_TO_RADIANS(-rot) );
	//[newUnit setRotation: (float)rot];
	
	cpSpaceAddBody(space, factory.body);
	
	factory.body->data = factory;
	
	cpShape *shape = cpCircleShapeNew(factory.body, unitSize, CGPointZero);
	
	// Add collision shape
	shape->e = 0.1f; shape->u = 3.0f;
	shape->data = factory;
	cpSpaceAddShape(space, shape);
	//cpSpaceAddStaticShape(space, shape);
	factory.shape1 = shape;
	
	factory.position = position;
	
	cpBodySetPos(factory.body, position);
	
	cpSpaceRehashStatic(space);
		
	return factory;
	
}

+ (Factory *) factoryFromData:(NSMutableDictionary *)savedData{
	
	if (savedData) {
		
		//int typeSaved = [[savedData objectForKey:@"type"] intValue];
		//int factionSaved = [[savedData objectForKey:@"faction"] intValue];
		
		cpFloat currentHPSaved = [[savedData objectForKey:@"currenthp"] floatValue];
		cpFloat positionXSaved = [[savedData objectForKey:@"positionx"] floatValue];
		cpFloat positionYSaved = [[savedData objectForKey:@"positiony"] floatValue];
		cpFloat rotationSaved = [[savedData objectForKey:@"rotation"] floatValue];
		
		int productionRateSaved = [[savedData objectForKey:@"productionrate"] intValue];
		int productionUnitSaved = [[savedData objectForKey:@"productionunit"] intValue];

		
		Factory *factorySaved = [self factoryWithSize:productionRateSaved withPosition:cpv(positionXSaved,positionYSaved)];
		
		if (factorySaved) {
			
			factorySaved.currentHitPoints = currentHPSaved;
			factorySaved.productionUnit = productionUnitSaved;
			
			//cpBodySetPos(factorySaved.body, CGPointMake(positionXSaved, positionYSaved));
			//factorySaved.position = CGPointMake(positionXSaved, positionYSaved);
			
			cpBodySetAngle(factorySaved.body, (float)CC_DEGREES_TO_RADIANS(-rotationSaved) );
			factorySaved.rotation = rotationSaved;
			
			[factorySaved stopAllActions];
			[factorySaved updateUnitHealthDisplay];
			
			NSLog(@"unit restored");
			return factorySaved;
		}
		NSLog(@"unit corrupt");
		
		return nil;
		
	}
	NSLog(@"unit corrupt");
	return nil;
	
}

- (Unit *) createUnitFromProduction {
	
	//Unit *unit = [Unit unitWithType:productionUnit withFaction:faction withPosition:self.position];
	
	return nil;
	
}

- (NSMutableDictionary *) saveableData{
	
	NSMutableDictionary *savedData = [super saveableData];
		
	[savedData setObject:[NSNumber numberWithInt:self.productionRate] forKey:@"productionrate"];
	[savedData setObject:[NSNumber numberWithInt:self.productionUnit] forKey:@"productionunit"];
	
	return savedData;
	
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
