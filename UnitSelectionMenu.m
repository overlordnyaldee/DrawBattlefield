//
//  UnitSelectionMenu.m
//  DrawBattlefield
//
//  Created by James Washburn on 5/19/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import "UnitSelectionMenu.h"
#import "Battleground.h"

@implementation UnitSelectionMenu

@synthesize faction;
@synthesize wasFighting;
@synthesize menu;
@synthesize backgroundLayer;

enum {
	kTagSprite = 1,
	kTagUnit = 2,
	kOptionMenu = 94935,
	kUnitSelection = 99304,
};

-(id) init{
	[super init];
	if ((self = [super init])) {
		
		[self setIsTouchEnabled:YES];
		
		self.backgroundLayer = [CCColorLayer layerWithColor:ccc4(0, 0, 0, 0)];
		[self addChild:backgroundLayer z:10];
		
		[backgroundLayer runAction:[CCFadeTo actionWithDuration:0.5f opacity:120]];
				
		[CCMenuItemFont setFontSize:24];
		
		
		CCMenuItemFont *friend = [CCMenuItemFont itemFromString: NSLocalizedString(@"Friendly", nil)];
		CCMenuItemFont *foe = [CCMenuItemFont itemFromString: NSLocalizedString(@"Hostile", nil)];
		
		CCMenuItemToggle *factionSelection = [CCMenuItemToggle 
											itemWithTarget:self 
											selector:@selector(changeFaction:) 
											items:friend, foe, nil];
		self.faction = kFactionFriend;
		
		CCMenuItemFont *soldier = [CCMenuItemFont itemFromString: [NSLocalizedString(@"soldier", nil) capitalizedString] 
													  target: self 
													selector: @selector(addSoldier:)];
		
		CCMenuItemFont *soldierOfficer = [CCMenuItemFont itemFromString: [NSLocalizedString(@"officer", nil) capitalizedString] 
															 target: self 
														   selector: @selector(addSoldierp:)];
		CCMenuItemFont *soldierArmored = [CCMenuItemFont itemFromString: [NSLocalizedString(@"armored soldier", nil) capitalizedString] 
															 target: self 
														   selector: @selector(addSoldiera:)];
		
		CCMenuItemFont *sniper = [CCMenuItemFont itemFromString: [NSLocalizedString(@"snipers", nil) capitalizedString] 
													 target:self 
												   selector:@selector(addSniper:)];
		CCMenuItemFont *poweredArmor = [CCMenuItemFont itemFromString: [NSLocalizedString(@"powered armor", nil) capitalizedString] 
														   target:self 
														 selector:@selector(addPoweredArmor:)];
		CCMenuItemFont *soldierRocket = [CCMenuItemFont itemFromString: [NSLocalizedString(@"rocket soldier", nil) capitalizedString] 
															target:self 
														  selector:@selector(addRocketSoldier:)];
		
		CCMenuItemFont *tankLight = [CCMenuItemFont itemFromString: [NSLocalizedString(@"light tank", nil) capitalizedString]  
														target:self 
													  selector:@selector(addTank:)];
		CCMenuItemFont *tankHeavy = [CCMenuItemFont itemFromString: [NSLocalizedString(@"heavy tank", nil) capitalizedString] 
														target:self 
													  selector:@selector(addTankp:)];
		CCMenuItemFont *turretLight = [CCMenuItemFont itemFromString: [NSLocalizedString(@"light turret", nil) capitalizedString]  
														  target:self 
														selector:@selector(addTurretl:)];
		CCMenuItemFont *turretHeavy = [CCMenuItemFont itemFromString: [NSLocalizedString(@"heavy turret", nil) capitalizedString]  
														  target:self 
														selector:@selector(addTurreth:)];
		
		CCMenuItemFont *shield = [CCMenuItemFont itemFromString: [NSLocalizedString(@"shield", nil) capitalizedString]  
														  target:self 
														selector:@selector(addShield:)];
		CCMenuItemFont *soldierDrill = [CCMenuItemFont itemFromString: [NSLocalizedString(@"drill soldier", nil) capitalizedString]  
														  target:self 
														selector:@selector(addDrillSoldier:)];
		
		CCMenuItemFont *close0 = [CCMenuItemFont itemFromString: NSLocalizedString(@"Return", nil)  
													 target: self 
												   selector: @selector(closeUnitSelection:)];
		
		self.menu = [CCMenu menuWithItems: soldier, soldierOfficer, soldierArmored, 
					  poweredArmor, sniper, soldierRocket, 
					  tankLight, tankHeavy, 
					  turretLight, turretHeavy,
					  shield, soldierDrill,
					  factionSelection, close0, 
					  nil];
		
		[menu alignItemsInColumns:[NSNumber numberWithUnsignedInt:3],
		 [NSNumber numberWithUnsignedInt:3], 
		 [NSNumber numberWithUnsignedInt:2], 
		 [NSNumber numberWithUnsignedInt:2],
		 [NSNumber numberWithUnsignedInt:2],
		 [NSNumber numberWithUnsignedInt:2], 
		 nil];
		
		[[friend label] setColor: ccc3(0, 255, 0)];
		[[foe label] setColor: ccc3(255, 0, 0)];
		
		[[soldier label] setColor: ccc3(240, 240, 240)];
		[[soldierOfficer label] setColor: ccc3(240, 240, 240)];
		[[soldierArmored label] setColor: ccc3(240, 240, 240)];
		[[poweredArmor label] setColor: ccc3(240, 240, 240)];
		[[sniper label] setColor: ccc3(240, 240, 240)];
		[[soldierRocket label] setColor: ccc3(240, 240, 240)];
		[[tankLight label] setColor: ccc3(240, 240, 240)];
		[[tankHeavy label] setColor: ccc3(240, 240, 240)];
		//[[turretLight label] setColor:ccc3(240, 240, 240)];
		//[[turretHeavy label] setColor:ccc3(240, 240, 240)];
		[[close0 label] setColor: ccc3(255, 0, 0)];
				
		[self addChild: menu z:90002];
		
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(orientationChanged:) 
													 name:@"UIDeviceOrientationDidChangeNotification" 
												   object:nil];
		
	}
	
	return self;
}

- (void) orientationChanged:(NSNotification *)notification {
	
	[backgroundLayer setContentSize:[[CCDirector sharedDirector] winSize]];
	
	[self.menu setPosition:[self center]];
	
}

- (void) onEnter {
	
	Battleground *battleground = (Battleground *)[self parent];
	
	self.wasFighting = ([battleground wasFighting] || [battleground isFighting]);
	
	//if (wasFighting) {
		[battleground pauseBattle];
	[battleground setIsTouchEnabled:NO];
		//}
	
	[super onEnter];
}

-(void)addSoldier:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeSoldier faction:self.faction];	
}
-(void)addSoldierp:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeSoldierOfficer faction:self.faction];	
}
-(void)addSoldiera:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeSoldierArmored faction:self.faction];	
}
-(void)addSniper:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeSniper faction:self.faction];	
}
-(void)addPoweredArmor:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypePoweredArmor faction:self.faction];	
}
-(void)addRocketSoldier:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeSoldierRocket faction:self.faction];	
}
-(void)addTank:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeTankLight faction:self.faction];	
}
-(void)addTankp:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeTankHeavy faction:self.faction];	
}
-(void)addTurretl:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeTurretLight faction:self.faction];	
}
-(void)addTurreth:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeTurretHeavy faction:self.faction];	
}
-(void)addShield:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeShield faction:self.faction];	
}
-(void)addDrillSoldier:(id) sender{
	[(Battleground *)[self parent] addUnitWithinCurrentViewWithType:kUnitTypeSoldierDrill faction:self.faction];	
}

-(void)closeUnitSelection:(id) sender{
	
	Battleground *battleground = (Battleground *)[self parent];
	
	if (wasFighting) {
		[battleground setIsFighting:self.wasFighting];
		[battleground resumeBattle];
	}
	[battleground setIsTouchEnabled:YES];
	[battleground removeChildByTag:kUnitSelection cleanup:YES];
}

-(void)changeFaction:(id) sender{
	if ([sender selectedIndex] == 0){
		faction = kFactionFriend;
	} else if ([sender selectedIndex] == 1) {
		faction = kFactionEnemy;
	}
}

- (CGPoint) center {
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	return CGPointMake(winSize.width/2, winSize.height/2);
	
}

-(void) onExit{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super onExit];
	
}

- (void)dealloc {
	self.menu = nil;
	self.backgroundLayer = nil;
    [super dealloc];
}
@end
