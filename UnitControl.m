//
//  UnitControl.m
//  DrawBattlefield
//
//  Created by James Washburn on 9/9/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import "UnitControl.h"

#import "chipmunk_unsafe.h"
#import "ccArray.h"

#import "Unit.h"
#import "Factory.h"
#import "Inkspot.h"

@implementation UnitControl

@synthesize parent;
@synthesize unitArray;
@synthesize factoryArray;
@synthesize inkspotArray;

@synthesize unitScale;

@dynamic unitCount;
@dynamic factoryCount;
@dynamic inkspotCount;

@synthesize unitsFriendly;
@synthesize unitsEnemy;

@synthesize factoriesFriendly;
@synthesize factoriesEnemy;

@synthesize unitToRemove_;

extern cpSpace *space;

- (id)init {
    if ((self = [super init])) {
		
		// Setup unit storage array
		//self.unitStorage = [NSMutableArray arrayWithCapacity:15];
		
		self.unitArray = ccArrayNew(1);
		self.factoryArray = ccArrayNew(1);
		self.inkspotArray = ccArrayNew(1);
		
		self.unitScale = 1.0f;
		
		self.unitsFriendly = 0;
		self.unitsEnemy = 0;
		
	}
	
    return self;
	
}

+ (id) unitControl{
	
	return [[[self alloc] init] autorelease];
	
}


- (void) addUnit:(Unit *)unit{
	
	if (unit.faction == kFactionFriend){
		self.unitsFriendly++;
	} else {
		self.unitsEnemy++;
	}

	if (self.unitArray->max == self.unitCount) {
		ccArrayDoubleCapacity(self.unitArray);
	}
	
	ccArrayAppendObject(self.unitArray, unit);
	
}

- (void) addUnit:(Unit *)unit withPosition:(CGPoint)position{
	
	[unit setPosition:position];
	
	[self addUnit:unit];
	
}

- (void) removeUnit:(Unit *)unitToRemove{

	[self removeUnit:unitToRemove withConfirm:NO];
	
}

- (void) removeUnit:(Unit *)unitToRemove withConfirm:(BOOL)confirm{
	
	if (unitToRemove) {
		
		if (confirm) {
			
			UIAlertView *infoMessage = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Delete Unit?" , nil)
																  message:[NSString stringWithFormat:
																		   NSLocalizedString(@"Are you sure you want to delete this %@?" , nil), 
																		   [Unit stringHumanReadableFromUnitType:unitToRemove.unitType]] 
																 delegate:self 
														cancelButtonTitle: NSLocalizedString(@"No" , nil)
														otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
			
			[[CCDirector sharedDirector] pause];
			
			[infoMessage show];
			
			self.unitToRemove_ = unitToRemove;
			
			[infoMessage autorelease];
			
		} else {
			
			if (unitToRemove.faction == kFactionFriend){
				
				self.unitsFriendly--;
				
			} else {
				
				self.unitsEnemy--;
				
			}
			
			[[unitToRemove parent] removeChild:unitToRemove cleanup:YES];
			
			ccArrayRemoveObject(self.unitArray, unitToRemove);
			
			unitToRemove = nil;
		}

	}
	
}

// Callback for unit delete confirm 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex != alertView.cancelButtonIndex) {
		if (unitToRemove_.faction == kFactionFriend){
			self.unitsFriendly--;
		} else {
			self.unitsEnemy--;
		}
				
		[[unitToRemove_ parent] removeChild:unitToRemove_ cleanup:YES];
				
		ccArrayRemoveObject(self.unitArray, unitToRemove_);
		
		unitToRemove_ = nil;
	}
	
	[[CCDirector sharedDirector] resume];

}

- (Unit *) randomUnit{
	
	if (unitArray->num == 0){
		return nil;
	}
	
	Unit *searchUnit = nil;
	
	while (searchUnit == nil) {
		
		//searchUnit = (Unit *) unitArray->arr[arc4random()%unitArray->num];
		searchUnit = (Unit *) unitArray->arr[AMARandom(0,(float)unitArray->num)];

		if ((searchUnit) && (searchUnit.unitType != kUnitTypeInkspot)) {
			return searchUnit;
		}
		
	}
	
		
	return searchUnit;
}

- (Unit *) randomUnitFromFaction:(int)faction{
	
	if (unitArray->num == 0){
		return nil;
	}
	
	// check for stuck loop because no faction exists
	int executionSanity = 0;
	
	Unit *searchUnit = nil;
	
	while (searchUnit == nil) {
		
		executionSanity++;
		
		//searchUnit = (Unit *) unitArray->arr[(int)((double)rand() / ((double)RAND_MAX + 1) * unitArray->num)];//arc4random()%unitArray->num];
		searchUnit = (Unit *) unitArray->arr[AMARandom(0,(float)unitArray->num)];//arc4random()%unitArray->num];

		if (([searchUnit faction] == faction) && (searchUnit.unitType != kUnitTypeInkspot)){
			
			return searchUnit;
			
		} else if (executionSanity > 500) {
			
			return nil;
			
		} else {
			
			searchUnit = nil;
			
		}
	}
	
	return nil;
}

- (Unit *) unitAtPosition:(CGPoint)position{
	
	return [self unitAtPosition:position withinPixels:1];
}

- (Unit *) unitAtPosition:(CGPoint)position withinPixels:(cpFloat)variance{
	
	CGRect searchArea = CGRectMake(position.x-variance, position.y-variance, variance*2, variance*2);
	
	Unit *searchUnit;
	
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = (Unit *) unitArray->arr[i];
		
		/*if ((searchUnit.unitType == kUnitTypeTurretHeavy) || (searchUnit.unitType == kUnitTypeTurretLight) || */
		
		if (CGRectContainsPoint(searchArea, [searchUnit position])){
			
			return searchUnit;
			
		}
		
	}
	
	return nil;
}

- (Unit *) unitAtPosition:(CGPoint)position withinRange:(cpFloat)variance withFaction:(int)faction{
	
	CGRect searchArea = CGRectMake(position.x-variance, position.y-variance, variance*2, variance*2);
	
	Unit *searchUnit;
	
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = (Unit *) unitArray->arr[i];
		
		if ((CGRectContainsPoint(searchArea, [searchUnit position])) && ([searchUnit faction] == faction)){
			
			return searchUnit;
			
		}
		
	}
	
	return nil;
}


- (BOOL) isAnyFactionEmpty{
	if ((unitsFriendly <= 0) || (unitsEnemy <= 0)){
		return TRUE;
	}
	return FALSE;
}

- (void) moveAllUnitsWithDifference:(CGPoint)position{
	
	Unit *searchUnit;
	
	cpBody *body;
	
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = (Unit *) unitArray->arr[i];
		
		body = searchUnit.body;
		
		CGPoint oldPosition = [searchUnit position];
		
		// take care of our x position
		cpFloat xdifference = oldPosition.x + position.x;
		
		// take care of our y position
		cpFloat ydifference = oldPosition.y + position.y;
		
		cpBodySlew(body, cpv(xdifference, ydifference), (cpFloat)1.0f*unitScale);		
	}
	
	/*Factory *searchFactory;
	
	for (int i = 0; i < factoryArray->num; i++){
		
		searchFactory = (Factory *) factoryArray->arr[i];
		
		body = searchFactory.body;
		
		CGPoint oldPosition = [searchFactory position];
		
		// take care of our x position
		cpFloat xdifference = oldPosition.x + position.x;
		
		// take care of our y position
		cpFloat ydifference = oldPosition.y + position.y;
		
		cpBodySlew(body, cpv(xdifference, ydifference), (cpFloat)0.1f*unitScale);	
		
	}
	
	Inkspot *searchInkspot;
	
	for (int i = 0; i < inkspotArray->num; i++){
		
		searchInkspot = (Inkspot *) inkspotArray->arr[i];
		
		body = searchInkspot.body;
		
		CGPoint oldPosition = [searchInkspot position];
		
		// take care of our x position
		cpFloat xdifference = oldPosition.x + position.x/10;
		
		// take care of our y position
		cpFloat ydifference = oldPosition.y + position.y/10;
		
		cpBodySlew(body, cpv(xdifference, ydifference), (cpFloat)0.1f*unitScale);	
		
	}*/
	
}

- (void) moveAllUnitsToPosition:(CGPoint)position{
	
	Unit *searchUnit;
	
	cpBody *body;
	
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = (Unit *) unitArray->arr[i];
		
		/*if ((searchUnit.unitType == kUnitTypeTurretHeavy) || (searchUnit.unitType == kUnitTypeTurretLight)) {
			continue;
		}*/
		
		if ((searchUnit.unitType == kUnitTypeInkspot) || (searchUnit.unitType == kUnitTypeFactory)) {
			continue;
		}
		
		body = searchUnit.body;
		
		CGPoint oldPosition = [searchUnit position];
		
		// take care of our x position
		cpFloat xdifference = oldPosition.x - position.x;
		
		// take care of our y position
		cpFloat ydifference = oldPosition.y - position.y;
		
		cpBodySlew(body, CGPointMake(oldPosition.x-xdifference, oldPosition.y-ydifference), (cpFloat)2.0f*unitScale);
		
	}
	
}


- (void) zoomInAllUnitsFromPosition:(CGPoint)position{
	
	Unit *searchUnit = nil;
	
	cpBody *body;
	
	if (self.unitScale > kZoomMax) {
		return;
	}
	
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = (Unit *) unitArray->arr[i];
		
		body = searchUnit.body;
		
		CGPoint oldPosition = [searchUnit position];
		
		// Calculate difference in position
		cpFloat xdifference =  (position.x - oldPosition.x)/2;
		cpFloat ydifference =  (position.y - oldPosition.y)/2;
		
		// Adjust physics shapes
		cpFloat r = cpCircleShapeGetRadius([searchUnit shape1]);
		cpCircleShapeSetRadius([searchUnit shape1], r+0.5f);
		
		
		cpBodySlew(body, CGPointMake(oldPosition.x-xdifference, oldPosition.y-ydifference) , 1);
		
		[searchUnit setScale:[searchUnit scale] + 0.02f];
		
		self.unitScale = self.unitScale + 0.02f;

		
	}
	
	for (int i = 0; i < factoryArray->num; i++){
		
		searchUnit = (Factory *) factoryArray->arr[i];
		
		body = searchUnit.body;
		
		CGPoint oldPosition = [searchUnit position];
		
		// Calculate difference in position
		cpFloat xdifference =  (position.x - oldPosition.x)/2;
		cpFloat ydifference =  (position.y - oldPosition.y)/2;
		
		// Adjust physics shapes
		cpFloat r = cpCircleShapeGetRadius([searchUnit shape1]);
		cpCircleShapeSetRadius([searchUnit shape1], r+0.5f);
		
		
		cpBodySlew(body, CGPointMake(oldPosition.x-xdifference, oldPosition.y-ydifference) , 1);
		
		[searchUnit setScale:[searchUnit scale] + 0.02f];
		
	}
	
	for (int i = 0; i < inkspotArray->num; i++){
		
		searchUnit = (Inkspot *) inkspotArray->arr[i];
		
		body = searchUnit.body;
		
		CGPoint oldPosition = [searchUnit position];
		
		// Calculate difference in position
		cpFloat xdifference =  (position.x - oldPosition.x)/2;
		cpFloat ydifference =  (position.y - oldPosition.y)/2;
		
		// Adjust physics shapes
		cpFloat r = cpCircleShapeGetRadius([searchUnit shape1]);
		cpCircleShapeSetRadius([searchUnit shape1], r+0.5f);
		
		
		cpBodySlew(body, CGPointMake(oldPosition.x-xdifference, oldPosition.y-ydifference) , 1);
		
		[searchUnit setScale:[searchUnit scale] + 0.02f];
		
	}
	
	self.unitScale = [searchUnit scale];
	
}

- (void) zoomOutAllUnitsFromPosition:(CGPoint)position{
	
	Unit *searchUnit = nil;
	cpBody *body;
	
	if (self.unitScale < kZoomMin) {
		return;
	}
	
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = (Unit *) unitArray->arr[i];
		
		body = searchUnit.body;
		
		CGPoint oldPosition = [searchUnit position];
		
		// Calculate difference in position
		cpFloat xdifference =  (position.x - oldPosition.x)/2;
		cpFloat ydifference =  (position.y - oldPosition.y)/2;
		
		cpFloat r = cpCircleShapeGetRadius([searchUnit shape1]);
		cpCircleShapeSetRadius([searchUnit shape1], r-0.5f);
		
		cpBodySlew(body, CGPointMake(oldPosition.x+xdifference, oldPosition.y+ydifference) , 1);
		
		[searchUnit setScale:[searchUnit scale] - 0.02f];
		
		self.unitScale = self.unitScale - 0.02f;
		
	}
	
	for (int i = 0; i < factoryArray->num; i++){
		
		searchUnit = (Factory *) factoryArray->arr[i];
		
		body = searchUnit.body;
		
		CGPoint oldPosition = [searchUnit position];
		
		// Calculate difference in position
		cpFloat xdifference =  (position.x - oldPosition.x)/2;
		cpFloat ydifference =  (position.y - oldPosition.y)/2;
		
		cpFloat r = cpCircleShapeGetRadius([searchUnit shape1]);
		cpCircleShapeSetRadius([searchUnit shape1], r-0.5f);
		
		cpBodySlew(body, CGPointMake(oldPosition.x+xdifference, oldPosition.y+ydifference) , 1);
		
		[searchUnit setScale:[searchUnit scale] - 0.02f];
		
	}
	
	for (int i = 0; i < inkspotArray->num; i++){
		
		searchUnit = (Inkspot *) inkspotArray->arr[i];
		
		body = searchUnit.body;
		
		CGPoint oldPosition = [searchUnit position];
		
		// Calculate difference in position
		cpFloat xdifference =  (position.x - oldPosition.x)/2;
		cpFloat ydifference =  (position.y - oldPosition.y)/2;
		
		cpFloat r = cpCircleShapeGetRadius([searchUnit shape1]);
		cpCircleShapeSetRadius([searchUnit shape1], r-0.5f);
		
		cpBodySlew(body, CGPointMake(oldPosition.x+xdifference, oldPosition.y+ydifference) , 1);
		
		[searchUnit setScale:[searchUnit scale] - 0.02f];
		
	}
	
	self.unitScale = [searchUnit scale];
	
}

// Heal all units HP by one
- (void) healAllUnits{
	
	Unit *searchUnit;
		
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = (Unit *) unitArray->arr[i];
		
		if (searchUnit.currentHitPoints < searchUnit.maxHitPoints) {
			
			searchUnit.currentHitPoints++;
			
			[searchUnit updateUnitHealthDisplay];
		
		}
		
	}
}

// Reset physics motion on all units
- (void) freezeAllUnits{
	
	Unit *searchUnit;
	
	cpBody *body;
	
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = (Unit *) unitArray->arr[i];
		
		body = searchUnit.body;
		
		if (body) {
			
			body->v = CGPointZero;
			body->w = 0;
			
		}
		
	}
		
	for (int i = 0; i < factoryArray->num; i++){
		
		searchUnit = (Factory *) factoryArray->arr[i];
		
		body = searchUnit.body;
		
		if (body) {
			
			body->v = CGPointZero;
			body->w = 0;
			
		}
		
	}
		
	for (int i = 0; i < inkspotArray->num; i++){
		
		searchUnit = (Inkspot *) inkspotArray->arr[i];
		
		body = searchUnit.body;
		
		if (body) {
			
			body->v = CGPointZero;
			body->w = 0;
			
		}
		
	}
	
}

// Remove and free all units
- (void) clearAllUnits{
	
	Unit *searchUnit;
		
	for (int i = 0; i < unitArray->num; i++){
	//for (Unit* searchUnit1 in ){

		searchUnit = (Unit *) unitArray->arr[i];
				
		[[searchUnit parent] removeChild:searchUnit cleanup:YES];
		
	}
	
	for (int i = 0; i < factoryArray->num; i++){
				
		searchUnit = (Factory *) factoryArray->arr[i];
		
		[[searchUnit parent] removeChild:searchUnit cleanup:YES];
		
	}
	
	for (int i = 0; i < inkspotArray->num; i++){
				
		searchUnit = (Inkspot *) inkspotArray->arr[i];
		
		[[searchUnit parent] removeChild:searchUnit cleanup:YES];
		
	}
	
	
	ccArrayRemoveAllObjects(self.unitArray);
	ccArrayRemoveAllObjects(self.factoryArray);
	ccArrayRemoveAllObjects(self.inkspotArray);
	
	self.unitsFriendly = 0;
	self.unitsEnemy = 0;
	self.factoriesFriendly = 0;
	self.factoriesEnemy = 0;
	
	cpResetShapeIdCounter();

}

// Update the health display of all units
- (void) updateHealthDisplayOfAllUnits{
	
	Unit *searchUnit;
	
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = (Unit *) unitArray->arr[i];
		
		[searchUnit updateUnitHealthDisplay];
		
	}
}

- (int) unitCount{
	return unitArray->num;
}

- (int) factoryCount{
	return factoryArray->num;
}

- (int) inkspotCount{
	return inkspotArray->num;
}


+ (int) opposingFactionOfFaction:(int)faction{
	
	if (faction == kFactionFriend){
		return kFactionEnemy;
	} else if (faction == kFactionEnemy){
		return kFactionFriend;
	}
	return -1;
}

+ (int) randomFaction{
	
	int chance = AMARandom(0,2.0f); //arc4random() % 2;
	
	if (chance){
		return kFactionFriend;
	} else {
		return kFactionEnemy;
	}

}

- (void) addFactory:(Factory *)factoryToAdd{
	
	if ([factoryToAdd faction] == kFactionFriend){
		self.factoriesFriendly++;
	} else {
		self.factoriesEnemy++;
	}
	
	
	ccArrayEnsureExtraCapacity(self.factoryArray, 1);
	
	ccArrayAppendObject(self.factoryArray, factoryToAdd);
	
}

- (void) addFactory:(Factory *)factoryToAdd withPosition:(CGPoint)position{
	
	[self addFactory:factoryToAdd];
	
	[factoryToAdd setPosition:position];

	
}

- (void) removeFactory:(Factory *)factoryToRemove {
	
	if ([factoryToRemove faction] == kFactionFriend){
		self.factoriesFriendly--;
	} else {
		self.factoriesEnemy--;
	}
	
	[[factoryToRemove parent] removeChild:factoryToRemove cleanup:YES];
	
	ccArrayRemoveObject(self.factoryArray, factoryToRemove);
	
	factoryToRemove = nil;
}

- (void) factoryProduceUnits {
	
	Factory *searchFactory;
	Unit *unitToAdd;
	
	for (int i = 0; i < factoryArray->num; i++){
		
		searchFactory = (Factory *) factoryArray->arr[i];
		
		unitToAdd = [searchFactory createUnitFromProduction];
		
		[self addUnit:unitToAdd];
		[parent addChild: unitToAdd z:kUnitZ tag:255];
		
	}
	
}

- (void) addInkspot:(Inkspot *)inkspotToAdd{
		
	ccArrayEnsureExtraCapacity(self.inkspotArray, 1);
	
	ccArrayAppendObject(self.inkspotArray, inkspotToAdd);
	
}

- (void) addInkspot:(Inkspot *)inkspotToAdd withPosition:(CGPoint)position{
	
	[self addInkspot:inkspotToAdd];
	
	[inkspotToAdd setPosition:position];
	
	
}

- (void) removeInkspot:(Inkspot *)inkspotToRemove {
		
	[[inkspotToRemove parent] removeChild:inkspotToRemove cleanup:YES];
	
	ccArrayRemoveObject(self.inkspotArray, inkspotToRemove);
	
	inkspotToRemove = nil;
}

- (NSMutableArray *) saveableDataForAllUnits {
	
	//NSMutableDictionary *savedData = [NSMutableDictionary dictionary];
	
	NSMutableArray *savedData = [NSMutableArray arrayWithCapacity:self.unitCount];
	
	[savedData addObject:[NSNumber numberWithFloat:self.unitScale]];
	[savedData addObject:[NSNumber numberWithInt:self.unitCount]];
	[savedData addObject:[NSNumber numberWithInt:self.factoryCount]];
	[savedData addObject:[NSNumber numberWithInt:self.inkspotCount]];


	int d = 0;
	
#ifdef DEBUG
	NSLog(@"saving units");
#endif
	
	Unit *searchUnit;
	
	for (int i = 0; i < unitArray->num; i++){
		
		searchUnit = unitArray->arr[i];
				
		[savedData addObject:[searchUnit saveableData]];
		
		d++;
		
	}
	
	Factory *searchFactory;
	
	for (int i = 0; i < factoryArray->num; i++){
		
		searchFactory = factoryArray->arr[i];
				
		[savedData addObject:[searchFactory saveableData]];
		
		d++;
		
	}
	
	Inkspot *searchInkspot;
	
	for (int i = 0; i < inkspotArray->num; i++){
		
		searchInkspot = inkspotArray->arr[i];
				
		[savedData addObject:[searchInkspot saveableData]];
		
		d++;
		
	}
	
#ifdef DEBUG
	NSLog(@"%d units saved", d);
#endif
	
	return savedData;
	
}

- (void) restoreUnitsFromSavedData:(NSMutableArray *)savedData{
	
	if (savedData) {
		
#ifdef DEBUG
		NSLog(@"reading in units");
#endif
		
		self.unitScale = [[savedData objectAtIndex:0] floatValue];
		
		int unitsStored = [[savedData objectAtIndex:1] intValue];
		int factoriesStored = [[savedData objectAtIndex:2] intValue];
		int inkspotsStored = [[savedData objectAtIndex:3] intValue];

		int d = 0;
		
#ifdef DEBUG
		NSLog(@"%d units present", [savedData count]-2);
#endif
		
		Unit *unitToAdd;
				
		for (int i = kFileFormatDataOffset; i < unitsStored + kFileFormatDataOffset; i++) {
			
			unitToAdd = [Unit unitFromData:[savedData objectAtIndex:i]];
			
			//NSLog(@"%d iteration", i);
			
			if (unitToAdd) {
				
				unitToAdd.scale = self.unitScale;
				
				double unitSize = 20 * [[parent unitSystem] unitScale];
				
				if ((unitToAdd.unitType == kUnitTypeTankHeavy) || 
					(unitToAdd.unitType == kUnitTypeTankLight) || 
					(unitToAdd.unitType == kUnitTypePoweredArmor)){
					
					unitSize = 30 * [[parent unitSystem] unitScale];
					
				}
				
				//cpCircleShapeSetRadius(unitToAdd.shape1, (cpFloat)unitSize);
				
				if (unitToAdd.shape1->klass->type == CP_CIRCLE_SHAPE) {
					cpCircleShapeSetRadius(unitToAdd.shape1, (cpFloat)unitSize);
				} else if ((unitToAdd.shape1->klass->type == CP_SEGMENT_SHAPE)) {
					cpSegmentShapeSetRadius(unitToAdd.shape1, (cpFloat)unitSize);
				}
				
				[self addUnit:unitToAdd];
				[parent addChild: unitToAdd z:kUnitZ tag:255];
				
				d++;
			} else {
				
#ifdef DEBUG
				NSLog(@"%d unit corrupt", i);
#endif
				
			}
			
		}
		
		Factory *factoryToAdd;
		
		for (int i = unitsStored + kFileFormatDataOffset; 
			 i < unitsStored + factoriesStored + kFileFormatDataOffset; i++) {
			
			factoryToAdd = [Factory factoryFromData:[savedData objectAtIndex:i]];
			
			//NSLog(@"%d iteration", i);
			
			if (factoryToAdd) {
				
				factoryToAdd.scale = self.unitScale;
				
				double unitSize = 40 * [[parent unitSystem] unitScale];
				
				cpCircleShapeSetRadius(factoryToAdd.shape1, (cpFloat)unitSize);
				
				
				[self addUnit:factoryToAdd];
				[parent addChild: factoryToAdd z:kUnitZ tag:255];
				
				d++;
			} else {
				
#ifdef DEBUG
				NSLog(@"%d unit corrupt", i);
#endif
				
			}
			
		}
		
		Inkspot *inkspotToAdd;
		
		for (int i = unitsStored + factoriesStored + kFileFormatDataOffset; 
			 i < unitsStored + factoriesStored + inkspotsStored + kFileFormatDataOffset; i++) {
			
			inkspotToAdd = [Inkspot inkspotFromData:[savedData objectAtIndex:i]];
			
			//NSLog(@"%d iteration", i);
			
			if (inkspotToAdd) {
				
				inkspotToAdd.scale = self.unitScale;
				
				double unitSize = 40 * [[parent unitSystem] unitScale];
				
				cpCircleShapeSetRadius(inkspotToAdd.shape1, (cpFloat)unitSize);
				
				
				[self addUnit:inkspotToAdd];
				[parent addChild: inkspotToAdd z:kUnitZ tag:255];
				
				d++;
			} else {
				
#ifdef DEBUG
				NSLog(@"%d unit corrupt", i);
#endif
				
			}
			
		}
		
#ifdef DEBUG
		NSLog(@"%d units read in", d);
#endif
		
	} else {
		
#ifdef DEBUG
		NSLog(@"saved units corrupt");
#endif
		
	}
	
}

- (void) dealloc {
		
	[self clearAllUnits];
	
	ccArrayFree(unitArray);
	ccArrayFree(factoryArray);
	ccArrayFree(inkspotArray);
	
	[super dealloc];
	
}

@end
