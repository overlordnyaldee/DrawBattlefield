//
//  Unit.m
//  DrawBattlefield
//
//  Created by James Washburn on 9/9/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
//  Extends CocosNode with unit specific functions

#import "Unit.h"


@implementation Unit

@synthesize faction;
@synthesize body;
@synthesize unitType;
@synthesize shape1;
//@synthesize shape2;
//@synthesize shape3;
@synthesize currentHitPoints;
@synthesize maxHitPoints;
@synthesize attack;
@synthesize armor;
@synthesize range;
@synthesize cost;
@synthesize bulletOffset;
@synthesize unitSystem;

extern cpSpace *space;

- (id)init {
    if ((self = [super init])) {
		
		//
		self.faction = INT_MIN;
		self.body = nil;
		self.unitType = INT_MIN;
		self.shape1 = nil;
		self.currentHitPoints = INT_MIN;
		self.maxHitPoints = INT_MIN;
		self.attack = INT_MIN;
		self.armor = INT_MIN;
		self.range = INT_MIN;
		self.cost = INT_MIN;

	}
	
    return self;
}


+ (Unit *) unitWithType:(int)type withFaction:(int)newFaction withPosition:(CGPoint)position{
	
	Unit *newUnit = [self unitWithType:type withFaction:newFaction withinCurrentView:YES];
	
	[newUnit setPosition:position];
	
	return newUnit;
}

+ (Unit *) unitWithType:(int)type withFaction:(int)newFaction{
	
	return [self unitWithType:type withFaction:newFaction withinCurrentView:YES];
	
}

//-----------------------------------------

+ (Unit *) unitWithType:(int)type withFaction:(int)newFaction withinCurrentView:(BOOL) isCurrentView{
	
	NSString *unitName = [Unit stringFromUnitType:type];
	
	if (type <= 0){
		return nil;
	}
	
	cpFloat hp = 0;
	int attackTemp = 0;
	int armorTemp = 0;
	int rangeTemp = 0;
	int costTemp = 0;
	
	if (type == kUnitTypeSoldier){
		hp = 2;
		attackTemp = 1;
		armorTemp = 1;
		rangeTemp = 120;
		costTemp = 1;
	} else if (type == kUnitTypeSoldierOfficer){
		hp = 4;
		attackTemp = 2;
		armorTemp = 1;
		rangeTemp = 120;
		costTemp = 2;
	} else if (type == kUnitTypeSoldierArmored){
		hp = 6;
		attackTemp = 4;
		armorTemp = 2;
		rangeTemp = 120;
		costTemp = 4;
	} else if (type == kUnitTypeSoldierRocket){
		hp = 2;
		attackTemp = 15;
		armorTemp = 1;
		rangeTemp = 200;
		costTemp = 5;
	} else if (type == kUnitTypeTurretHeavy){
		hp = 10;
		attackTemp = 3;
		armorTemp = 3;
		rangeTemp = 220;
		costTemp = 0;
	} else if (type == kUnitTypeTurretLight){
		hp = 10;
		attackTemp = 2;
		armorTemp = 2;
		rangeTemp = 220;
		costTemp = 0;
	} else if (type == kUnitTypeTankHeavy){
		hp = 10;
		attackTemp = 8;
		armorTemp = 4;
		rangeTemp = 360;
		costTemp = 10;
	} else if (type == kUnitTypeTankLight){
		hp = 10;
		attackTemp = 4;
		armorTemp = 2;
		rangeTemp = 200;
		costTemp = 8;
	} else if (type == kUnitTypeSniper){
		hp = 6;
		attackTemp = 4;
		armorTemp = 2;
		rangeTemp = 600;
		costTemp = 5;
	} else if (type == kUnitTypePoweredArmor){
		hp = 10;
		attackTemp = 2;
		armorTemp = 2;
		rangeTemp = 200;
		costTemp = 4;
	} else if (type == kUnitTypeFactory) {
		return nil;
	} else if (type == kUnitTypeInkspot) {
		return nil;
	} else if (type == kUnitTypeShield) {
		hp = 100;
		attackTemp = 0;
		armorTemp = 1;
		rangeTemp = 0;
		costTemp = 5;
	} else if (type == kUnitTypeSoldierDrill) {
		hp = 6;
		attackTemp = 10;
		armorTemp = 2;
		rangeTemp = 50;
		costTemp = 4;
	}
	
	Unit *newUnit = [super spriteWithTexture:[[CCTextureCache sharedTextureCache] 
											  addPVRTCImage:[unitName stringByAppendingPathExtension:@"pvrtc"] 
											  bpp:4 
											  hasAlpha:YES 
											  width:128]];
	
	newUnit.faction = newFaction;
	newUnit.body = nil;
	newUnit.shape1 = nil;
	newUnit.unitType = type;
	
	hp = hp*10;
	rangeTemp = rangeTemp / 1;
	
	newUnit.maxHitPoints = hp;
	newUnit.currentHitPoints = hp;
	newUnit.attack = attackTemp*2;
	newUnit.armor = armorTemp*2;
	newUnit.range = rangeTemp;
	newUnit.cost = costTemp;
	
	int unitSize = 20;
	
	int newX;
	int newY;
	
	if (!isCurrentView) {
		newX = (arc4random() % ((int)[[CCDirector sharedDirector] winSize].width+200))-100;
		newY = (arc4random() % ((int)[[CCDirector sharedDirector] winSize].height+200))-100;
	} else {
		newX = (arc4random() % ((int)[[CCDirector sharedDirector] winSize].width));
		newY = (arc4random() % ((int)[[CCDirector sharedDirector] winSize].height));
	}
	
	// Add collision body
	cpBody *body;
	
	if ((type == kUnitTypeTurretHeavy) || 
		(type == kUnitTypeTurretLight) ||
		(type == kUnitTypeShield)){
		body = cpBodyNew(5000.0f, 5000.0f);
	} else {
		body = cpBodyNew(100.0f, cpMomentForCircle(100.0f, unitSize, unitSize, CGPointZero));
	}

	
	// Set position
	cpBodySetPos(body, ccp(newX, newY));
	
	//Set rotation
	double rot = ((double)rand() / ((double)RAND_MAX + 1) * 360); 
	cpBodySetAngle(body, (float)CC_DEGREES_TO_RADIANS(-rot) );
	[newUnit setRotation: (float)rot];
	
	cpSpaceAddBody(space, body);
	
	body->data = newUnit;
	
	cpShape *shape;
	
	if (type == kUnitTypeShield) {
		shape = cpSegmentShapeNew(body, ccp(-20,0), ccp(20,0), 1);
	} else {
		shape = cpCircleShapeNew(body, unitSize, CGPointZero);
	}

	
	// Add collision shape
	shape->e = 0.1f; shape->u = 3.0f;
	shape->data = newUnit;
	shape->collision_type = kCollisionTypeUnit;
	cpSpaceAddShape(space, shape);
	[newUnit setShape1:shape];
	
	[newUnit setBody:body];
	
	
	[newUnit setPosition: ccp(newX,newY)];
	
	if (newUnit.faction == kFactionFriend){
		[newUnit setFaction:1];
		[newUnit runAction:[CCTintTo actionWithDuration:1 red:150 green:255 blue:150]];
	} else if (newUnit.faction == kFactionEnemy){
		[newUnit setFaction:2];
		[newUnit runAction:[CCTintTo actionWithDuration:1 red:255 green:150 blue:150]];
	} 
	
	return newUnit;
	
}

+ (Unit *) unitWithinCurrentViewWithType:(int)type withFaction:(int)newFaction{
	
	return [self unitWithType:type withFaction:newFaction withinCurrentView:YES];
}

+ (Unit *) unitFromData:(NSMutableDictionary *)savedData {
	
	if (savedData) {
		
		int typeSaved = [[savedData objectForKey:@"type"] intValue];
		int factionSaved = [[savedData objectForKey:@"faction"] intValue];
		
		cpFloat currentHPSaved = [[savedData objectForKey:@"currenthp"] floatValue];
		cpFloat positionXSaved = [[savedData objectForKey:@"positionx"] floatValue];
		cpFloat positionYSaved = [[savedData objectForKey:@"positiony"] floatValue];
		cpFloat rotationSaved = [[savedData objectForKey:@"rotation"] floatValue];
		
		Unit *unitSaved = [self unitWithType:typeSaved withFaction:factionSaved withPosition:CGPointMake(positionXSaved, positionYSaved)];
		
		if (unitSaved) {
			
			unitSaved.currentHitPoints = currentHPSaved;
			cpBodySetPos(unitSaved.body, CGPointMake(positionXSaved, positionYSaved));
			unitSaved.position = CGPointMake(positionXSaved, positionYSaved);
			cpBodySetAngle(unitSaved.body, (float)CC_DEGREES_TO_RADIANS(-rotationSaved) );
			unitSaved.rotation = rotationSaved;
			[unitSaved stopAllActions];
			[unitSaved updateUnitHealthDisplay];
			
#ifdef DEBUG
			NSLog(@"unit restored");
#endif

			return unitSaved;
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

- (NSMutableDictionary *) saveableData{
	
	NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	[savedData setObject:[NSNumber numberWithFloat:DrawBattlefieldSavedBattlegroundVersion] forKey:@"version"];
	
	[savedData setObject:[NSNumber numberWithInt:self.unitType] forKey:@"type"];
	[savedData setObject:[NSNumber numberWithInt:self.faction] forKey:@"faction"];
	[savedData setObject:[NSNumber numberWithFloat:self.currentHitPoints] forKey:@"currenthp"];
	
	[savedData setObject:[NSNumber numberWithFloat:self.position.x] forKey:@"positionx"];
	[savedData setObject:[NSNumber numberWithFloat:self.position.y] forKey:@"positiony"];
	
	[savedData setObject:[NSNumber numberWithFloat:self.rotation] forKey:@"rotation"];
	
	return savedData;
	
}

+ (NSString *) stringFromUnitType:(int) type {
	
	NSMutableString *unitName = nil;
	
	if (type == kUnitTypeSoldier){
		unitName = [NSString stringWithString:@"soldier"];
	} else if (type == kUnitTypeSoldierOfficer){
		unitName = [NSString stringWithString:@"soldierofficer"];
	} else if (type == kUnitTypeSoldierArmored){
		unitName = [NSString stringWithString:@"soldierarmored"];
	} else if (type == kUnitTypeSoldierRocket){
		unitName = [NSString stringWithString:@"soldierrocket"];
	} else if (type == kUnitTypeTurretHeavy){
		unitName = [NSString stringWithString:@"turretheavy"];
	} else if (type == kUnitTypeTurretLight){
		unitName = [NSString stringWithString:@"turretlight"];
	} else if (type == kUnitTypeTankHeavy){
		unitName = [NSString stringWithString:@"tankheavy"];
	} else if (type == kUnitTypeTankLight){
		unitName = [NSString stringWithString:@"tanklight"];
	} else if (type == kUnitTypeSniper){
		unitName = [NSString stringWithString:@"sniper"];
	} else if (type == kUnitTypePoweredArmor){
		unitName = [NSString stringWithString:@"poweredarmor"];
	} else if (type == kUnitTypeFactory){
		unitName = [NSString stringWithString: @"factory"];
	} else if (type == kUnitTypeInkspot){
		unitName = [NSString stringWithString: @"inkspot"];
	} else if (type == kUnitTypeShield) {
		unitName = [NSString stringWithString: @"shield"];
	} else if (type == kUnitTypeSoldierDrill) {
		unitName = [NSString stringWithString: @"soldierdrill"];
	}
	
	return unitName;
}

+ (NSString *) stringHumanReadableFromUnitType:(int) type {
	
	NSMutableString *unitName = nil;
	
	if (type == kUnitTypeSoldier){
		unitName = [NSString stringWithString: NSLocalizedString(@"soldier", nil)];
	} else if (type == kUnitTypeSoldierOfficer){
		unitName = [NSString stringWithString: NSLocalizedString(@"officer", nil)];
	} else if (type == kUnitTypeSoldierArmored){
		unitName = [NSString stringWithString: NSLocalizedString(@"armored soldier", nil)];
	} else if (type == kUnitTypeSoldierRocket){
		unitName = [NSString stringWithString: NSLocalizedString(@"rocket soldier", nil)];
	} else if (type == kUnitTypeTurretHeavy){
		unitName = [NSString stringWithString: NSLocalizedString(@"heavy turret", nil)];
	} else if (type == kUnitTypeTurretLight){
		unitName = [NSString stringWithString: NSLocalizedString(@"light turret", nil)];
	} else if (type == kUnitTypeTankHeavy){
		unitName = [NSString stringWithString: NSLocalizedString(@"heavy tank", nil)];
	} else if (type == kUnitTypeTankLight){
		unitName = [NSString stringWithString: NSLocalizedString(@"light tank", nil)];
	} else if (type == kUnitTypeSniper){
		unitName = [NSString stringWithString: NSLocalizedString(@"sniper", nil)];
	} else if (type == kUnitTypePoweredArmor){
		unitName = [NSString stringWithString: NSLocalizedString(@"powered armor", nil)];
	} else if (type == kUnitTypeFactory){
		unitName = [NSString stringWithString: NSLocalizedString(@"factory", nil)];
	} else if (type == kUnitTypeInkspot){
		unitName = [NSString stringWithString: NSLocalizedString(@"inkspot", nil)];
	} else if (type == kUnitTypeShield) {
		unitName = [NSString stringWithString: NSLocalizedString(@"shield", nil)];
	} else if (type == kUnitTypeSoldierDrill) {
		unitName = [NSString stringWithString: NSLocalizedString(@"drill soldier", nil)];
	}
	
	return unitName;
}

- (void) damageByAmount:(double)damage{
	
	// TODO - use a real algorithm for battle damage
	
	self.currentHitPoints = self.currentHitPoints-(cpFloat)((cpFloat)damage / (cpFloat)self.armor);
	
}

- (void) updateUnitHealthDisplay{
	
		if (self.faction == kFactionEnemy) {
			
			[self runAction:[CCTintTo actionWithDuration:0.1f red:[self getHealthColor] green:150 blue:150]];
			
		} else if (self.faction == kFactionFriend){
			
			[self runAction:[CCTintTo actionWithDuration:0.1f red:150 green:[self getHealthColor] blue:150]];
			
		}
	
}

- (int) getHealthColor{
	
	return (cpFloat)([self currentHitPoints] / [self maxHitPoints]) * 70 + 185;
	
}

- (id) spriteWithTexture:(CCTexture2D*) tex {
	
	return [CCSprite spriteWithTexture:tex];
	
}

- (void) cleanup {
	
	if (body) {
		if (cpArrayContains(space->bodies, body)) {
			cpSpaceRemoveBody(space, self.body);
			cpBodyFree(self.body);
		}
		self.body = nil;
	}
	
	if (shape1) {
		if (cpHashSetFind(space->activeShapes->handleSet, shape1->hashid, shape1)) {
			cpSpaceRemoveShape(space, self.shape1);
			cpShapeFree(self.shape1);
		}
		self.shape1 = nil;
	}
	
	[super cleanup];
}

- (void) dealloc {
	
	
	
	[super dealloc];
		
}

@end
