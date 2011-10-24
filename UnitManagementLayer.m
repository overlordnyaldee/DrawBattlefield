//
//  UnitManagementLayer.m
//  DrawBattlefield
//
//  Created by James Washburn on 9/28/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import "UnitManagementLayer.h"

#import "Unit.h"
#import "MainMenuLayer.h"

@interface UnitManagementLayer (private)
- (void) setUnitSoldier:(id) sender;
- (void) setUnitSoldierOfficer:(id) sender;
- (void) setUnitSoldierArmored:(id) sender;
- (void) setUnitSoldierRocket:(id) sender;
- (void) setUnitSniper:(id) sender;
- (void) setUnitPoweredArmor:(id) sender;
- (void) setUnitTankLight:(id) sender;
- (void) setUnitTankHeavy:(id) sender;
- (void) setUnitTurretLight:(id) sender;
- (void) setUnitTurretHeavy:(id) sender;
- (void) setUnitShield:(id) sender;
- (void) setUnitSoldierDrill:(id) sender;
- (void) returnToMain: (id) sender;
@end

@implementation UnitManagementLayer

@synthesize menu;
@synthesize displayUnit;

@synthesize displayHP;
@synthesize displayAttack;
@synthesize displayArmor;
@synthesize displayRange;
@synthesize sidebar;

static CGFloat deviceScalingX, deviceScalingY;

- (id)init {
    if ((self = [super init])) {
		
        // Initialization code
		self.isTouchEnabled = YES;
		
		// WARNING - ACCELEROMETER DISABLED
		self.isAccelerometerEnabled = NO;
		//[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
		
		// Seed the random number generator
		//srand((unsigned int)[[NSDate date] timeIntervalSince1970]);
		
		[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
		

		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			deviceScalingX = (CGFloat) (768.0/320.0);
			deviceScalingY = (CGFloat) (1024.0/480.0);
		} else {
			deviceScalingX = 1;
			deviceScalingY = 1;
		}
		
		/*Sprite *backgroundLayer = [[Sprite alloc]initWithFile:@"winterbackground.png"];
		 [backgroundLayer setPosition:cpv(240,160)];
		 [self addChild: backgroundLayer z:-1];
		 [backgroundLayer autorelease];*/
		
		CCSprite *backgroundLayer = [CCColorLayer layerWithColor:ccc4(200, 200, 200, 255)];
		[self addChild: backgroundLayer];
		//[backgroundLayer runAction:[TintTo actionWithDuration:1 red:200 green:200 blue:200]];
		
		[CCMenuItemFont setFontSize:18*deviceScalingY];
		
		CCMenuItemFont *soldier = [CCMenuItemFont itemFromString: @"Light Infantry" target:self selector:@selector(setUnitSoldier:)];
		
		CCMenuItemFont *soldierOfficer = [CCMenuItemFont itemFromString: @"Officer" target:self selector:@selector(setUnitSoldierOfficer:)];
		CCMenuItemFont *soldierArmored = [CCMenuItemFont itemFromString: @"Armored Infantry" target:self selector:@selector(setUnitSoldierArmored:)];
		
		CCMenuItemFont *sniper = [CCMenuItemFont itemFromString: @"Sniper" target:self selector:@selector(setUnitSniper:)];
		CCMenuItemFont *poweredArmor = [CCMenuItemFont itemFromString: @"Powered Armor" target:self selector:@selector(setUnitPoweredArmor:)];
		CCMenuItemFont *soldierRocket = [CCMenuItemFont itemFromString: @"Rocket Infantry" target:self selector:@selector(setUnitSoldierRocket:)];
		
		CCMenuItemFont *tankLight = [CCMenuItemFont itemFromString: @"Light Tank" target:self selector:@selector(setUnitTankLight:)];
		CCMenuItemFont *tankHeavy = [CCMenuItemFont itemFromString: @"Heavy Tank" target:self selector:@selector(setUnitTankHeavy:)];
		CCMenuItemFont *turretLight = [CCMenuItemFont itemFromString: @"Light Turret" target:self selector:@selector(setUnitTurretLight:)];
		CCMenuItemFont *turretHeavy = [CCMenuItemFont itemFromString: @"Heavy Turret" target:self selector:@selector(setUnitTurretHeavy:)];
		
		CCMenuItemFont *shield = [CCMenuItemFont itemFromString: @"Shield" target:self selector:@selector(setUnitShield:)];
		CCMenuItemFont *soldierDrill = [CCMenuItemFont itemFromString: @"Drill Infantry" target:self selector:@selector(setUnitSoldierDrill:)];

		CCMenuItemFont *closeItem = [CCMenuItemFont itemFromString: @"Return" target:self selector:@selector(returnToMain:)];
		
		[[closeItem label] setColor:ccc3(0, 0, 0)];
		
		self.menu = [CCMenu menuWithItems: soldier, soldierOfficer, soldierArmored, 
					  soldierRocket, sniper, poweredArmor,
					  tankLight, tankHeavy, 
					  turretLight, turretHeavy, 
					  shield, soldierDrill,
					  closeItem, 
					  nil];
		
		[menu alignItemsVertically];
		
		[menu setPosition:ccp(380*deviceScalingY,160*deviceScalingY)];
		

		[self addChild:menu];
		
		CCLabelTTF *displayLabel = [CCLabelTTF labelWithString:@"Unit Management" fontName:@"Marker Felt" fontSize:32*deviceScalingX];
		
		self.displayHP = [CCLabelTTF labelWithString:@"Health: ---" fontName:@"Marker Felt" fontSize:28*deviceScalingX];
		self.displayAttack = [CCLabelTTF labelWithString:@"Attack: ---" fontName:@"Marker Felt" fontSize:28*deviceScalingX];
		self.displayArmor = [CCLabelTTF labelWithString:@"Armor: ---" fontName:@"Marker Felt" fontSize:28*deviceScalingX];
		self.displayRange = [CCLabelTTF labelWithString:@"Range: ---" fontName:@"Marker Felt" fontSize:28*deviceScalingX];
		
		[displayLabel setPosition:cpv(120*deviceScalingX, 295*deviceScalingY)];
		[displayHP setPosition:cpv(80*deviceScalingX, 260*deviceScalingY)];
		[displayAttack setPosition:cpv(80*deviceScalingX, 230*deviceScalingY)];
		[displayArmor setPosition:cpv(80*deviceScalingX, 200*deviceScalingY)];
		[displayRange setPosition:cpv(80*deviceScalingX, 170*deviceScalingY)];
		
		[self addChild: displayLabel];
		[self addChild: displayHP];
		[self addChild: displayAttack];
		[self addChild: displayArmor];
		[self addChild: displayRange];
		
		[CCMenuItemFont setFontSize:32*deviceScalingY];
		
		self.sidebar = [CCSprite spriteWithFile:@"sidebar.png"];
		sidebar.position = ccp(470*deviceScalingY,160*deviceScalingY);
		sidebar.scale = deviceScalingY;
		[self addChild:sidebar];
		
		CCSprite *sidebar2 = [CCSprite spriteWithFile:@"sidebar.png"];
		sidebar2.position = ccp(290*deviceScalingY,160*deviceScalingY);
		sidebar2.scale = deviceScalingY;
		[self addChild:sidebar2];
		
		[self schedule:@selector(rotateUnit)];
						
    }
	
    return self;
	
}

-(void) onExit{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super onExit];
	
}

- (void) updateUnitStatistics{
	
	[displayHP setString:[@"Health: " stringByAppendingFormat:@"%3.0lf", displayUnit.maxHitPoints, nil]];
	[displayAttack setString:[@"Attack: " stringByAppendingFormat:@"%3d", displayUnit.attack, nil]];
	[displayArmor setString:[@"Armor: " stringByAppendingFormat:@"%3d", displayUnit.armor, nil]];
	[displayRange setString:[@"Range: " stringByAppendingFormat:@"%3d", displayUnit.range, nil]];
	
	//displayUnit.scale = 1.5;

}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
	//return YES;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
	UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
	
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch1 locationInView: [touch1 view]]];	
	CGPoint previoustouchPoint = [[CCDirector sharedDirector] convertToGL:[touch1 previousLocationInView: [touch1 view]]];	

	if (CGRectContainsPoint(CGRectMake(340*deviceScalingX, 0*deviceScalingY, 140*deviceScalingX, 320*deviceScalingY), touchPoint)){
		
		menu.position = ccp(menu.position.x, menu.position.y + (touchPoint.y - previoustouchPoint.y));
		
		sidebar.position = ccp(sidebar.position.x, sidebar.position.y + (touchPoint.y - previoustouchPoint.y));
		
	} 
	
	//return YES;
}



- (void) draw{  
	/*
	 glColor4f(1.0, 1.0, 1.0, 1.0);
	 cpSpaceHashEach(space->activeShapes, &drawObject, NULL);
	 glColor4f(1.0, 1.0, 1.0, 0.7);
	 cpSpaceHashEach(space->staticShapes, &drawObject, NULL);  	
	 */
}



@end

@implementation UnitManagementLayer (private)

- (void) setUnitSoldier:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeSoldier withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) rotateUnit {
	
	if (displayUnit) {
		
		self.displayUnit.rotation+= 1.0f;
		
	}

}

- (void) setUnitSoldierOfficer:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeSoldierOfficer withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) setUnitSoldierArmored:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeSoldierArmored withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) setUnitSoldierRocket:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeSoldierRocket withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) setUnitSniper:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeSniper withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) setUnitPoweredArmor:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypePoweredArmor withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}
- (void) setUnitTankLight:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeTankLight withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) setUnitTankHeavy:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeTankHeavy withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) setUnitTurretLight:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeTurretLight withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) setUnitTurretHeavy:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeTurretHeavy withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) setUnitShield:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeShield withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

- (void) setUnitSoldierDrill:(id) sender {
	
	if (displayUnit) {
		
		[self removeChild:displayUnit cleanup:YES];
		
	}
	
	self.displayUnit = [Unit unitWithType:kUnitTypeSoldierDrill withFaction:kFactionFriend];
	displayUnit.position = cpv(160*deviceScalingX, 80*deviceScalingY);
	displayUnit.rotation = 180;
	displayUnit.scale = deviceScalingX;
	[self addChild:displayUnit];
	[self updateUnitStatistics];
}

-(void) returnToMain: (id) sender {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:1 scene:[MainMenuLayer node]]];
}

@end
