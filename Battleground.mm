//
//  Battleground.m
//  DrawBattlefield
//
//  Created by James Washburn on 5/18/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//

#import "Battleground.h"
#import "OpenFeint.h"
#import "OFAchievementService.h"

#import "DebugRendering.m"
#import "DrawBattlefieldAppDelegate.h"
#import "MainMenuLayer.h"
#import "chipmunk_unsafe.h"
#import "UnitControl.h"
#import "UnitSelectionMenu.h"
#import "factions.h"
#import "Bullet.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation Battleground

@synthesize typeOfBattleground;
@synthesize unitSystem;
@synthesize selectedUnit;
@synthesize previousTouch;
@synthesize previousTouch2;
@synthesize offsetUnits;
@synthesize isFighting;
@synthesize wasFighting;
@synthesize vibrateOptionOff;
@synthesize shouldDisplayMovementBox;
@synthesize backgroundLayer;
@synthesize menu;
@synthesize challengeAchievementID;
@synthesize kills;

// Various C based methods needed for physics engine
extern cpBody* makeCircle(int radius);
extern void drawObject(void *ptr, void *unused);
extern void makeStaticBox(float x, float y, float width, float height);
static void eachShape(void *ptr, void* unused);
//int bulletCollisionFunc(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data);
int bulletCollisionFunc(cpArbiter *arb, cpSpace *space, void *data);
cpSpace *space = NULL;
cpBody *staticBody = NULL;


enum {
	kOptionMenu = 94935,
	kBattlegroundMenu = 92342,
	kUnitSelection = 99304,
};

#pragma mark Initialization

- (id)init {
    if ((self = [super init])) {
		
        // Initialization code
		self.isTouchEnabled = YES;
		
		// WARNING - ACCELEROMETER DISABLED
		self.isAccelerometerEnabled = NO;
		//[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
		
		// Seed the random number generator
		srand((cpFloat)[[NSDate date] timeIntervalSince1970]);
		
		self.isFighting = NO;
				
		// Unit Control System init
		self.unitSystem = [UnitControl unitControl];
		unitSystem.unitScale = 0.6f;
		unitSystem.parent = self;
		
		self.backgroundLayer = [CCColorLayer layerWithColor:ccc4(200, 200, 200, 150)];
		backgroundLayer.tag = 90101;
		[self addChild: backgroundLayer];
		
		self.typeOfBattleground = kBattlegroundFreeMode;
		self.challengeAchievementID = nil;
		
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(orientationChanged:) 
													 name:@"UIDeviceOrientationDidChangeNotification" 
												   object:nil];
		
		// Get vibrate option from app delegate
		DrawBattlefieldAppDelegate *appDelegate = (DrawBattlefieldAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.vibrateOptionOff = appDelegate.vibrateOptionOff;
		
		self.shouldDisplayMovementBox = NO;
		
		//self.offsetUnits = cpv([[Director sharedDirector] winSize].width/2, [[Director sharedDirector] winSize].height/2);
		self.offsetUnits = cpv(0, 0);

    }
	
    return self;
	
}

// tell the director that the orientation has changed
- (void) orientationChanged:(NSNotification *)notification {
	
	const unsigned int numOrientations = 4;
    UIInterfaceOrientation myOrientations[numOrientations] = { 
        UIInterfaceOrientationPortrait, UIInterfaceOrientationLandscapeLeft, 
        UIInterfaceOrientationLandscapeRight, UIInterfaceOrientationPortraitUpsideDown
    };
	
	// temp fix, right and left landscape have to be switched, no idea why
    
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if (true){ //UIDeviceOrientationIsLandscape(orientation) {
		
		if (orientation == UIDeviceOrientationLandscapeLeft) {
			
			[OpenFeint shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight
									withSupportedOrientations:myOrientations 
													 andCount:numOrientations];
			
			[OpenFeint setDashboardOrientation:UIInterfaceOrientationLandscapeRight];
			[[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeLeft];
			
		} else if (orientation == UIDeviceOrientationLandscapeRight) {
			
			[OpenFeint shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft
									withSupportedOrientations:myOrientations 
													 andCount:numOrientations];
			
			[OpenFeint setDashboardOrientation:UIInterfaceOrientationLandscapeLeft];
			[[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeRight];
			
		} else if ((orientation == UIDeviceOrientationPortrait) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
			
			[OpenFeint shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait
									withSupportedOrientations:myOrientations 
													 andCount:numOrientations];
			
			[OpenFeint setDashboardOrientation:UIInterfaceOrientationLandscapeRight];
			[[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationPortrait];
			
		} else if ((orientation == UIDeviceOrientationPortraitUpsideDown) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
			
			[OpenFeint shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown
									withSupportedOrientations:myOrientations 
													 andCount:numOrientations];
			
			[OpenFeint setDashboardOrientation:UIInterfaceOrientationLandscapeRight];
			[[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationPortraitUpsideDown];
			
		} 
		
		
	}
	
	/* 
	 
	 if (true){ //UIDeviceOrientationIsLandscape(orientation) {
	 
	 if (orientation == UIDeviceOrientationLandscapeLeft) {
	 
	 [OpenFeint shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft 
	 withSupportedOrientations:myOrientations 
	 andCount:numOrientations];
	 
	 //[OpenFeint setDashboardOrientation:UIInterfaceOrientationLandscapeLeft];
	 [[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeLeft];
	 
	 } else if (orientation == UIDeviceOrientationLandscapeRight) {
	 
	 [OpenFeint shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight 
	 withSupportedOrientations:myOrientations 
	 andCount:numOrientations];
	 
	 //[OpenFeint setDashboardOrientation:UIInterfaceOrientationLandscapeRight];
	 [[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeRight];
	 
	 } else if ((orientation == UIDeviceOrientationPortrait) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
	 
	 [OpenFeint shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait
	 withSupportedOrientations:myOrientations 
	 andCount:numOrientations];
	 
	 //[OpenFeint setDashboardOrientation:UIInterfaceOrientationLandscapeRight];
	 [[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationPortrait];
	 
	 } else if ((orientation == UIDeviceOrientationPortraitUpsideDown) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
	 
	 [OpenFeint shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown
	 withSupportedOrientations:myOrientations 
	 andCount:numOrientations];
	 
	 //[OpenFeint setDashboardOrientation:UIInterfaceOrientationLandscapeRight];
	 [[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationPortraitUpsideDown];
	 
	 } 
	 
	 
	 }
	 
	 */
	
	[backgroundLayer setContentSize:[[CCDirector sharedDirector] winSize]];
	
	int offset = 210;
	
	// Limit menu for challenge
	if (self.typeOfBattleground == kBattlegroundChallenge) {
		offset = 110;
	}
	
	//[menu alignItemsHorizontallyWithPadding:16];
	//[menu setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width-offset,-15)];
	
	if ([menu position].y == 15) {
		[menu setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width-offset,15)];
	} else {
		[menu setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width-offset,-15)];
	}
	
}

+ (id) battleground {
	
	Battleground *battleground = [[self alloc] init];
	
	// User interface explanation
	UIAlertView *infoMessage = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Instructions", nil)
														  message: NSLocalizedString(@"One touch to move, two taps to remove, touch bottom right for menu", nil) 
														 delegate: battleground 
												cancelButtonTitle: NSLocalizedString(@"Done", nil)
												otherButtonTitles: nil];
	
	[infoMessage show];
	[infoMessage autorelease];
	
	
	return [battleground autorelease];
}

+ (id) mainMenuBackground{
	
	Battleground *battleground = [[[self alloc] init] autorelease];
	battleground.isTouchEnabled = NO;
	battleground.isFighting = YES;
	battleground.typeOfBattleground = kBattlegroundMainMenuBackground;
	battleground.unitSystem.unitScale = 0.5f;
	
	[battleground setVisible:NO];
	
	return battleground;
	
}

+ (id) battlegroundWithSavedBattleground:(NSString *)file{
	
	Battleground *battleground = [[[self alloc] init] autorelease];
	
	if (!file) {
		[battleground readBattlegroundFromFile:[Battleground defaultSavedDataFile]]; 
	} else {
		[battleground readBattlegroundFromFile:file]; 
		battleground.isFighting = YES;
	}
	
	return battleground;
	
}

+ (id) battlegroundWithSavedChallenge:(NSString *)challengeType{
	
	Battleground *battleground = [[[self alloc] init] autorelease];
	
	if ([challengeType isEqualToString:kBattlegroundChallengeTypeSniper]) {
		battleground.challengeAchievementID = @"76033";
	} else if ([challengeType isEqualToString:kBattlegroundChallengeTypeArmored]){
		battleground.challengeAchievementID = @"76043";
	} else if ([challengeType isEqualToString:kBattlegroundChallengeTypeTurret]){
		battleground.challengeAchievementID = @"76053";
	} else if ([challengeType isEqualToString:kBattlegroundChallengeTypeTank1]){
		battleground.challengeAchievementID = @"76063";
	} else if ([challengeType isEqualToString:kBattlegroundChallengeTypeTank2]){
		battleground.challengeAchievementID = @"76073";
	}
	
	battleground.typeOfBattleground = kBattlegroundChallenge;
	[battleground readBattlegroundFromFile:[[NSBundle mainBundle] pathForResource:challengeType ofType:@"plist"]]; 
	battleground.isFighting = YES;
	
	return battleground;
	
}

// Execute after transistion finishes
- (void) onEnterTransitionDidFinish{
	
	// Physics API init
	[self initChipmunk];
	
	// Graphics/physics engine init
	[self schedule:@selector(step:)];
	
	// Fighting init
	if (self.isFighting) {
		[self schedule:@selector(fightBattle)];
	}
	
	self.wasFighting = self.isFighting;
	
	// Notification for app termination
	if (self.typeOfBattleground != kBattlegroundMainMenuBackground) {
		[self setupMenu];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationWillTerminate:) 
													 name:UIApplicationWillTerminateNotification 
												   object:[UIApplication sharedApplication]];
	} else {
		[self spawnRandomUnits];
		[self schedule:@selector(checkEmptyFaction) interval:1];
		[self setVisible:YES];
	}
	
	// OpenFeint dashboard icon init (only display if approved or main menu background)
	if ([OpenFeint hasUserApprovedFeint] && (self.typeOfBattleground != kBattlegroundMainMenuBackground)){
		
		CCSprite *openFeintSprite = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"openfeintmenu1.png"]];	
		
		CCMenuItemSprite *openFeintMenuItem = [CCMenuItemSprite itemFromNormalSprite:openFeintSprite 
																  selectedSprite:openFeintSprite 
																		  target:self 
																		selector:@selector(loadDashboard:)];
		[openFeintMenuItem setScale:0.25f];
		
		CCMenu *menuOpenFeint = [CCMenu menuWithItems:openFeintMenuItem, nil];
		[menuOpenFeint setPosition:cpv(34, 30)];
		[self addChild:menuOpenFeint z:INT_MAX];
		
	}
	
	/*int newX, newY;
	 
	 for (int i = 0; i < 2; i++){
	 newX = (arc4random() % ((int)[[Director sharedDirector] winSize].width));
	 newY = (arc4random() % ((int)[[Director sharedDirector] winSize].height));
	 
	 Inkspot *inkSpot = [Inkspot inkspotWithPosition:cpv(newX, newY)];
	 [self addChild:inkSpot];
	 [unitSystem addInkspot:inkSpot];
	 
	 newX = (arc4random() % ((int)[[Director sharedDirector] winSize].width));
	 newY = (arc4random() % ((int)[[Director sharedDirector] winSize].height));
	 
	 Factory *factory = [Factory factoryWithSize:kFactorySizeMedium withPosition:cpv(newX, newY)];
	 [self addChild:factory];
	 [unitSystem addFactory:factory];
	 }*/
	
	// Register touches
	//[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:10];
	
}

// Initialize Chipmunk Physics
- (void) initChipmunk {
	// start chipumnk
	// create the space for the bodies
	// and set the hash to a rough estimate of how many shapes there could be
	// set gravity, make the physics run loop
	// make a bounding box the size of the screen
	
	if (!space){
		
		space = cpSpaceNew();
		
		cp_collision_slop = 0.001f;
		cp_bias_coef = 1.01f;
		
		cpSpaceResizeStaticHash(space, 4, 20);
		cpSpaceResizeActiveHash(space, 12.0f, 500);
		
		space->gravity = cpv(0, 0);
		space->damping = 0.08f;
		space->iterations = 200;
		space->elasticIterations = 200;
		
		if (!staticBody){
			
			staticBody = cpBodyNew(INFINITY, INFINITY);  
			
		}
		
		//cpSpaceAddCollisionPairFunc(space, kCollisionTypeBullet, kCollisionTypeUnit, bulletCollisionFunc, self);
		/*cpSpaceAddCollisionHandler(space, kCollisionTypeBullet, kCollisionTypeUnit, 
								   bulletCollisionFunc, NULL, NULL, NULL, self);*/
		
	} else {
				
		//cpSpaceFreeChildren(space);
		//cpSpaceFree(space);
		//space = cpSpaceNew();

	}
	
	cpSpaceAddCollisionHandler(space, kCollisionTypeBullet, kCollisionTypeUnit, 
							   NULL, bulletCollisionFunc, NULL, NULL, self);
	
}

//int bulletCollisionFunc(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data){

//cpCollisionBeginFunc
int bulletCollisionFunc(cpArbiter *arb, cpSpace *space, void *data){

	cpShape *a,*b;
	cpArbiterGetShapes(arb, &a, &b);
	
	Battleground *battleground = (Battleground *) data;
		
	Bullet *bulletShot = (Bullet *)a->data;
	Unit *unitHit = (Unit *)b->data;
	
	
	// Sanity checks
	if ((battleground == nil) ||(bulletShot == nil) || (unitHit == nil)) {
		return 0;
	}
	if ((a->collision_type != kCollisionTypeBullet) || (b->collision_type != kCollisionTypeUnit)) {
		return 0;
	}
	
	// Shouldn't be hit by own bullet
	if (bulletShot.unitShotFrom == unitHit){
		return 0;
	}
	
	// Shields: friendly fire passes through
	if (unitHit.unitType == kUnitTypeShield) {
		
		if (bulletShot.unitShotFrom.faction == unitHit.faction) {
			return 0;
		}

	}
	
	if (unitHit.currentHitPoints < 0){
		return 0;
	} else {
		[unitHit damageByAmount:bulletShot.damage];
	}	
	
	if (unitHit.currentHitPoints < 0) {
		
		if (battleground.typeOfBattleground != kBattlegroundMainMenuBackground) {
			battleground.kills++;
			[battleground checkKillCountAchievement];
		}
		
		[battleground createExplosionWithPosition:unitHit.position];
		
		// WARNING - freeing a Unit in a collision func will cause strange crashes
		[battleground.unitSystem performSelector:@selector(removeUnit:) withObject:unitHit afterDelay:0];
		
	} else {
		[unitHit updateUnitHealthDisplay];
	}
	
	return 1;
}

#pragma mark Unit Management

- (void)spawnRandomUnits{
	
	int numOfUnitsGenerated = ((int)((double)rand() / ((double)RAND_MAX + 1) * 20)) + 40;
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypeSoldier];
		
	}
	
	numOfUnitsGenerated = ((int)((double)rand() / ((double)RAND_MAX + 1) * 15)) + 10;
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypeSoldierOfficer];
		
	}
	// ---
	numOfUnitsGenerated = (int)((double)rand() / ((double)RAND_MAX + 1) * 3);
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypeTurretLight];
		
	}
	
	numOfUnitsGenerated = (int)((double)rand() / ((double)RAND_MAX + 1) * 1);
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypeTurretHeavy];
		
	}
	// ----
	numOfUnitsGenerated = (int)((double)rand() / ((double)RAND_MAX + 1) * 4);
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypeTankLight];
		
	}
	
	numOfUnitsGenerated = (int)((double)rand() / ((double)RAND_MAX + 1) * 2);
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypeTankHeavy];
		
	}
	
	numOfUnitsGenerated = (int)((double)rand() / ((double)RAND_MAX + 1) * 10);
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypeSoldierArmored];
		
	}
	
	numOfUnitsGenerated = ((int)((double)rand() / ((double)RAND_MAX + 1) * 4)) + 1;
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypeSniper];
		
	}
	
	numOfUnitsGenerated = (int)((double)rand() / ((double)RAND_MAX + 1) * 6);
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypePoweredArmor];
		
	}
	
	numOfUnitsGenerated = (int)((double)rand() / ((double)RAND_MAX + 1) * 5);
	
	for (int i = 0; i < numOfUnitsGenerated; i++){
		
		[self addUnitWithType:kUnitTypeSoldierRocket];
		
	}
	
	cpResetShapeIdCounter();
	
}

-(void) addUnitWithType:(int) unitType{
	
	// Random hostile or friendly unit
	
	int chance = arc4random() % 2;
	
	if (chance){
		[self addUnitWithType:unitType faction:kFactionFriend];
	} else {
		[self addUnitWithType:unitType faction:kFactionEnemy];
	}
}

-(void) addUnitWithType:(int) unitType faction:(int)faction withinCurrentView:(BOOL)isCurrentView{
	
	Unit *newUnit = [Unit unitWithType:unitType withFaction:faction withinCurrentView:isCurrentView];
	
	double unitSize = 20 * [unitSystem unitScale];
	
	if ((unitType == kUnitTypeTankHeavy) || (unitType == kUnitTypeTankLight) || (unitType == kUnitTypePoweredArmor)){
		unitSize = 30 * [unitSystem unitScale];
	}
	
	if (newUnit.shape1->klass->type == CP_CIRCLE_SHAPE) {
		cpCircleShapeSetRadius(newUnit.shape1, (cpFloat)unitSize);
	} else if ((newUnit.shape1->klass->type == CP_SEGMENT_SHAPE)) {
		cpSegmentShapeSetRadius(newUnit.shape1, (cpFloat)unitSize);
	}

	
	
	//cpCircleShapeSetRadius(newUnit.shape1, (cpFloat)unitSize);
	
	[self addChild: newUnit z:kUnitZ tag:255];
	
	[newUnit setScale:[unitSystem unitScale]*1.5f];
	
	[newUnit runAction:[CCScaleTo actionWithDuration:1.0f scale:[unitSystem unitScale]]];
	
	[unitSystem addUnit:newUnit];
	
}

-(void) addUnitWithType:(int) unitType faction:(int)faction{
	
	[self addUnitWithType:unitType faction:faction withinCurrentView:NO];
	
}

-(void) addUnitWithinCurrentViewWithType:(int) unitType faction:(int)faction{
	
	[self addUnitWithType:unitType faction:faction withinCurrentView:YES];
	
}

-(void) clearUnitsOnField: (id) sender{
	
	UIAlertView *infoMessage = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Clear All Units?", nil) 
														  message:[NSString stringWithFormat:
																   NSLocalizedString(@"Are you sure you want to clear all units?", nil)] 
														 delegate:self 
												cancelButtonTitle:NSLocalizedString(@"No", nil) 
												otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
	[[CCDirector sharedDirector] pause];
	[infoMessage show];
	[infoMessage autorelease];
	
	// annoying behavior, you clear units to add more 99% of the time
	//[self toggleMenu:sender];
			
}

#pragma mark Fight Management

-(void)fightBattle{
	
#define ROTATETIME 0.15f
#define BULLETTIME 0.25f
	
	//cpSpaceAddCollisionPairFunc(space, kCollisionTypeBullet, kCollisionTypeUnit, bulletCollisionFunc, self);
	int factionOfAttacker = [UnitControl randomFaction];

	// Select units
	Unit *unitDidAttack = [unitSystem randomUnitFromFaction:factionOfAttacker];
	Unit *unitToExplode = [unitSystem unitAtPosition:[unitDidAttack position] 
										 withinRange:[unitDidAttack range]*[unitSystem unitScale] 
										 withFaction:[UnitControl opposingFactionOfFaction:factionOfAttacker]];
	
	// Detect if no units are found
	if (unitDidAttack == nil){
		return;
	} 
	
	// Detect if unit is busy
	if ([unitDidAttack numberOfRunningActions] > 1) {
		return;
	}
	
	int sanity = 0;
	while (unitDidAttack.unitType == kUnitTypeShield) {
		unitDidAttack = [unitSystem randomUnitFromFaction:factionOfAttacker];
		if (sanity > 100) {
			return;
		}
		sanity++;
	}
	
	CGPoint p0 = [unitDidAttack position];
	
	// No other unit in range, move
	if (unitToExplode == nil) {
		
		if ((unitDidAttack.unitType == kUnitTypeTurretLight) || 
			(unitDidAttack.unitType == kUnitTypeTurretHeavy) || 
			(unitDidAttack.unitType == kUnitTypeShield)) {
			return;
		}
		
		/*int sanity = 0;
		while ((unitDidAttack.unitType == kUnitTypeTurretLight) || 
			   (unitDidAttack.unitType == kUnitTypeTurretHeavy) || 
			   (unitDidAttack.unitType == kUnitTypeShield) ) {
			unitDidAttack = [unitSystem randomUnitFromFaction:factionOfAttacker];
			if (sanity > 100) {
				return;
			}
			sanity++;
		}*/
		
		Unit * unitToMoveTo = [unitSystem randomUnitFromFaction:[UnitControl opposingFactionOfFaction:factionOfAttacker]];
		
		CGPoint moveTo = CGPointZero;
		
		if (unitToMoveTo){
			moveTo = ccpMidpoint([unitDidAttack position], [unitToMoveTo position]);
		} else {
			return;
		}		
		
		cpBodySlew([unitDidAttack body], moveTo, unitSystem.unitScale*125.0f*(cpFloat)[[CCDirector sharedDirector] animationInterval]);
		
		[unitDidAttack runAction:[CCSequence actions: 
								  [CCRotateTo actionWithDuration:0.01f 
														 angle:CC_RADIANS_TO_DEGREES(atan2f(moveTo.x - p0.x, moveTo.y - p0.y))-180.0f], 
								  //[DelayTime actionWithDuration:1], 
								  //[CallFuncN actionWithTarget:self selector:@selector(adjustPosition:)], 
								  nil]];
		
		return;
	}

	
	CGPoint p1 = [unitToExplode position];
	
	float angle1 = atan2f(p1.x - p0.x, p1.y - p0.y);
	
	[unitDidAttack runAction:[CCSequence actions: 
							   [CCRotateTo actionWithDuration:ROTATETIME angle:CC_RADIANS_TO_DEGREES(angle1)-180.0f], 
							  //[DelayTime actionWithDuration:ROTATETIME], 
							  //[CallFuncN actionWithTarget:self selector:@selector(adjustPosition:)], 
							   nil]];
	
	
	Bullet *bullet = [Bullet bulletwithScale: unitSystem.unitScale 
						   withUnitAttacking: unitDidAttack 
							 toUnitDefending: unitToExplode];
	
	[self addChild:bullet];
	
	cpBodySlew(bullet.bulletBody, unitToExplode.position, BULLETTIME);
	
	[bullet runAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:BULLETTIME * 2.0f],
					   [CCCallFuncN actionWithTarget:self selector:@selector(removeBullet:)],
					   nil]];
	
	if (self.typeOfBattleground == kBattlegroundChallenge) {
		
		if ([unitSystem unitsEnemy] == 0) {
			
			if (self.challengeAchievementID) {
				
				[OFAchievementService unlockAchievement:self.challengeAchievementID];
				
			}
		}
	}
		
}

- (void) createExplosionWithPosition:(CGPoint) position {
	
	// TODO --- move explosions with units, possibly based on UnitControl
		
	CCParticleSystem *explosion = [CCParticleSun node];
	[explosion setPosition:position];
	
	[self addChild:explosion z:2];
	
	if ((self.vibrateOptionOff == NO) && (self.typeOfBattleground != kBattlegroundMainMenuBackground)) {
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		CGRect rect = CGRectMake(0, 0, size.width , size.height);
		
		if (CGRectContainsPoint(rect, position)){
			
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			
		}		
	}
	
	// Cleanup
	[explosion runAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.1f], 
						  [CCCallFunc actionWithTarget:explosion selector:@selector(stopSystem)],
						  [CCDelayTime actionWithDuration:1.5f], 
						  [CCCallFuncN actionWithTarget:self selector:@selector(removeEffect:)],
						  nil]];
	
}

- (void) adjustPosition:(id)node{
	
	Unit *unit1 = (Unit *) node;
	
	float angle = [unit1 rotation];
	
	cpBodySetAngle([unit1 body], CC_DEGREES_TO_RADIANS(-angle));
	
}

- (void) removeBullet: (id)node {
	
	[[node parent] removeChild:node cleanup:YES];
	
}

- (void) removeUnit: (id)node {
	
	[unitSystem removeUnit:node withConfirm:NO];
	[self removeChild:node cleanup:YES];
	
}

- (void) removeEffect: (id)node{
	
	[[node parent] removeChild:node cleanup:YES];
	
}

#pragma mark Touch Management

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if (self.isFighting) {
		[self pauseBattle];
	}
	
	// Ignore touch if unit selection menu is displayed
	if ([self getChildByTag:kUnitSelection] != nil){
		return;
		//return kEventIgnored;
	}
	
    switch ([touches count]) {
			
        case 1: {
			
			UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
			
			self.previousTouch = [[CCDirector sharedDirector] convertToGL:[touch1 locationInView: [touch1 view]]];	
			self.previousTouch2 = cpv(-1,-1);
			
			Unit *unitAtTouch = [unitSystem unitAtPosition:previousTouch withinPixels:20];
			
			if ([touch1 tapCount] == 2){
				
				if ((unitAtTouch.unitType != kUnitTypeInkspot) || (unitAtTouch.unitType != kUnitTypeFactory)) {
					
					if (self.typeOfBattleground != kBattlegroundChallenge) {
						
						[unitSystem removeUnit:unitAtTouch withConfirm:YES];
						
					}
					
				} else {
					// replace inkspot with factory
				}
				
				
				
			} /*else if ([touch1 tapCount] == 3) {
			   
			   if ([menu position].y == 15) {
			   
			   [self hideMenu:touch1];
			   
			   } else {
			   
			   [self showMenu:touch1];
			   
			   }
			   }*/
			
			self.selectedUnit = [unitSystem unitAtPosition:previousTouch withinPixels:20];
			
			if ((self.selectedUnit.unitType == kUnitTypeInkspot) || (self.selectedUnit.unitType == kUnitTypeFactory)) {
				self.selectedUnit = nil;
			}
			
			if (self.selectedUnit != nil){
				
				if (self.wasFighting) {
					self.isFighting = self.wasFighting;
					[self resumeBattle];
				}
				
				cpBody *body = selectedUnit.body;
				
				if (body) {
					
					body->v = CGPointZero;
					body->w = 0;
					
				}
				
			} 
			
        } break;
			
        case 2: {
			
            //get out two fingers
            UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
			
			self.previousTouch = [[CCDirector sharedDirector] convertToGL:[touch1 locationInView: [touch1 view]]];  
			self.previousTouch2 = [[CCDirector sharedDirector] convertToGL:[touch2 locationInView: [touch2 view]]];
			
        } break;
    }
	
	//return YES;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
	// Detect if unit selection is displayed
	if ([self getChildByTag:kUnitSelection] != nil){
		//return kEventIgnored;
		return;
	}
    
	switch ([touches count])
    {
        case 1: { 
			
			UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
			
			CGPoint newTouch = [[CCDirector sharedDirector] convertToGL:[touch1 locationInView: [touch1 view]]];			
			
			if (self.selectedUnit != nil){
				
				
				if ((self.selectedUnit.unitType != kUnitTypeInkspot) || (self.selectedUnit.unitType != kUnitTypeFactory)) {
					
					if ((self.typeOfBattleground == kBattlegroundChallenge) && (self.selectedUnit.faction == kFactionEnemy)) {
						return;// TRUE;
					}
					
					cpBody *touchedBody = [self.selectedUnit body];
					
					if (touchedBody) {
						
						cpBodySlew(touchedBody, newTouch, 0.1f*unitSystem.unitScale);//0.75f*unitSystem.unitScale);
						
					}
					
					
				}
				
			} else {
				
				if ([touch1 tapCount] == 1){
					
					self.shouldDisplayMovementBox = YES;
					
					CGPoint difference = ccpSub(newTouch, previousTouch);
					
					CGPoint tempOffset = cpv(self.offsetUnits.x-difference.x, self.offsetUnits.y-difference.y);
					
					CGSize winSize = [[CCDirector sharedDirector] winSize];
					
					
					//2010-03-18 21:37:54.866 DrawBattlefield[38275:207] X: 3462.000000 - Y: 1701.000000

					if (tempOffset.x > winSize.width*7){
						
						//return;// FALSE;

					}
					
					/*-winSize.width/15*8)*/
					
					if (tempOffset.x < 0) {
						//return;// FALSE;

					}
						
					if (tempOffset.y > winSize.height*7) {
						
						//return;// FALSE;

					}
					/*-winSize.height/15*8)*/ 
						
					if (tempOffset.y < 0) {
						
						//return;// FALSE;
					}
					
					[unitSystem moveAllUnitsWithDifference:difference];
					
					self.offsetUnits = tempOffset;
					
				} else if ([touch1 tapCount] == 2) {
					
					if (self.typeOfBattleground == kBattlegroundChallenge) {
						return;// TRUE;
					}
					
					[unitSystem moveAllUnitsToPosition:newTouch];
					
				}
				
			}
			
        } break;
        case 2: { 
			//Zoom
			
			UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
			
			CGPoint newTouch1 = [[CCDirector sharedDirector] convertToGL:[touch1 locationInView: [touch1 view]]]; 
			CGPoint newTouch2 = [[CCDirector sharedDirector] convertToGL:[touch2 locationInView: [touch2 view]]];  
			
			CGPoint oldTouch1 = [[CCDirector sharedDirector] convertToGL:[touch1 previousLocationInView: [touch1 view]]];
			CGPoint oldTouch2 = [[CCDirector sharedDirector] convertToGL:[touch2 previousLocationInView: [touch2 view]]];
			
			double newDistance = ccpDistance(newTouch1, newTouch2);
			double oldDistance = ccpDistance(oldTouch1, oldTouch2);
			
			if (newDistance > oldDistance) {
				[unitSystem zoomInAllUnitsFromPosition:ccpMidpoint(newTouch1, newTouch2)];
			} else if (newDistance < oldDistance) {
				[unitSystem zoomOutAllUnitsFromPosition:ccpMidpoint(newTouch1, newTouch2)];
			}
			
        } break;
    }
	
	//return YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	//return [self ccTouchesCancelled:touches withEvent:event];
	[self ccTouchesCancelled:touches withEvent:event];
}

- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	
	self.selectedUnit = nil;
	
	self.previousTouch = cpv(-1,-1);
	self.previousTouch2 = cpv(-1,-1);
	
	self.shouldDisplayMovementBox = NO;
	
	[unitSystem freezeAllUnits];
	
	
	if (self.wasFighting) {
		self.isFighting = self.wasFighting;
		[self resumeBattle];
	}
	
	return YES;
	
}


// Debug - draw physics collision shapes
- (void) draw{
	
	/*
	 
	 glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	cpSpaceHashEach(space->activeShapes, &drawObject, NULL);
	glColor4f(1.0f, 1.0f, 1.0f, 0.7f);
	cpSpaceHashEach(space->staticShapes, &drawObject, NULL);  
	
	cpArray *bodies = space->bodies;
	int num = bodies->num;
	
	glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
	for(int i=0; i<num; i++){
		cpBody *body = (cpBody *)bodies->arr[i];
		ccDrawPoint( ccp(body->p.x, body->p.y) );
	}
	
	glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
	cpArrayEach(space->arbiters, &drawCollisions, NULL);
	 
		
	*/
	
}

-(void) onExit{
	
	//cpSpaceRemoveCollisionPairFunc(space, kCollisionTypeBullet, kCollisionTypeUnit);
	cpSpaceRemoveCollisionHandler(space, kCollisionTypeBullet, kCollisionTypeUnit);

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	//[self pauseBattle];
	//[self unschedule:@selector(step:)];
	
	//[[ActionManager sharedManager] removeAllActions];
	
	//[self deactivateTimers];
	
	//[self removeAllChildrenWithCleanup:YES];
			
	[super onExit];
	
}

- (void) dealloc {
	
	//[self unschedule:@selector(step:)];
	
	//cpSpaceRemoveCollisionPairFunc(space, kCollisionTypeBullet, kCollisionTypeUnit);
	//cpSpaceRemoveCollisionHandler(space, kCollisionTypeBullet, kCollisionTypeUnit);

	[unitSystem clearAllUnits];
		
	if (selectedUnit) {
		[selectedUnit release];
	}
	
	// Release unit variables
	[unitSystem release];
	
	[backgroundLayer release];
	[menu release];
	
	[super dealloc];
	
}

#pragma mark Saved Battleground Management

+ (NSString *) defaultSavedDataFile{
	
	// Return full path of saved data file in app Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	return [documentsDirectory stringByAppendingString:kFileName];
	
}

+ (NSString *) savedDataFileWithName:(NSString *) name{
	
	// Return full path of saved data file in app Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	return [documentsDirectory stringByAppendingString:name];
	
}

// Save battle to file
- (BOOL) saveBattlegroundToFile:(NSString *)file {
	
	if (!file) {
		file = [Battleground defaultSavedDataFile];
	} else {
		file = [Battleground savedDataFileWithName:file];
	}
	
	NSMutableArray *savedData = [NSMutableArray arrayWithCapacity:5];
	
	[savedData addObject:@"DrawBattlefield Saved Battleground"];
	[savedData addObject:[NSNumber numberWithInt:DrawBattlefieldSavedBattlegroundVersion]];
	[savedData addObject:[NSNumber numberWithInt:self.typeOfBattleground]];
	[savedData addObject:[NSNumber numberWithBool:self.isFighting]];
	[savedData addObject:[unitSystem saveableDataForAllUnits]];
	if (self.challengeAchievementID) {
		[savedData addObject:self.challengeAchievementID];
	}
	
	return [savedData writeToFile: file atomically:YES];
}

// Read battle from file
- (BOOL) readBattlegroundFromFile:(NSString *)file {
	
	
#ifdef DEBUG
	NSLog(@"looking for saved");
#endif
	// Load from plist
	
	NSArray *savedData;
	
	if (file) {
		savedData = [NSArray arrayWithContentsOfFile:file];
	} else {
		savedData = [NSArray arrayWithContentsOfFile:[Battleground defaultSavedDataFile]];
	}
	
	// Detect if saved exists
	if (savedData != nil){
#ifdef DEBUG
		NSLog(@"file found");
#endif
		// version check
		if ([[savedData objectAtIndex:1] intValue] == DrawBattlefieldSavedBattlegroundVersion){
#ifdef DEBUG
			NSLog(@"version correct, loading");
#endif
			int typeSaved = [[savedData objectAtIndex:2] intValue];
			
			/*if (self.typeOfBattleground != typeSaved) {
				NSLog(@"wrong type bg");
				//return FALSE;
			}*/
			
			self.typeOfBattleground = typeSaved;
			self.isFighting = [[savedData objectAtIndex:3] boolValue];
			
			if ([savedData objectAtIndex:4] != nil) {
				[unitSystem restoreUnitsFromSavedData:[savedData objectAtIndex:4]];
			}
			
			if ([savedData count] >= 6) {
				if ([savedData objectAtIndex:5] != nil) {
					self.challengeAchievementID = [savedData objectAtIndex:5];
				}
			}
			
			return TRUE;
			
		} else {
#ifdef DEBUG
			NSLog(@"version %d incorrect, deleting", [[savedData objectAtIndex:1] intValue]);
#endif
			[[NSFileManager defaultManager] removeItemAtPath:[Battleground defaultSavedDataFile] error:NULL];
			
			return FALSE;
		}
		
	} else {
#ifdef DEBUG
		NSLog(@"not found");
#endif
		return FALSE;
		
	}
	
}

// App closing, save current battle
- (void) applicationWillTerminate:(UIApplication*)application {
	
	//if ((Battleground *)[[Director sharedDirector] runningScene] == self) {
		
		// Debug
		//NSLog(@"saving file as %@", [Battleground defaultSavedDataFile]);
		//NSLog(@"written? %d", [self saveBattlegroundToFile:[Battleground defaultSavedDataFile]]);
		
		[self saveKillCountFromSession];
		
		//[Battleground defaultSavedDataFile];
		[self saveBattlegroundToFile:nil];
	//}
	
} 

//@end

//@implementation Battleground (private)

#pragma mark Menu Management

// Initialize menu
- (void) setupMenu {
	
	[CCMenuItemFont setFontSize:28];
	
	CCMenuItemFont *item0 = [CCMenuItemFont itemFromString: NSLocalizedString(@"Add Unit", nil)
												target: self 
											  selector: @selector(showUnitSelection:)];
	
	CCMenuItemFont *pause0 = [CCMenuItemFont itemFromString: NSLocalizedString(@"Pause", nil)];
	CCMenuItemFont *resume = [CCMenuItemFont itemFromString: NSLocalizedString(@"Resume", nil)];
	
	CCMenuItemToggle *startStop = [CCMenuItemToggle itemWithTarget: self 
													  selector: @selector(startStop:) 
														 items: pause0, resume, nil];
	
	CCMenuItemFont *item1 = [CCMenuItemFont itemFromString: NSLocalizedString(@"Clear", nil) 
												target: self 
											  selector: @selector(clearUnitsOnField:)];
	
	CCMenuItemFont *item2 = [CCMenuItemFont itemFromString: NSLocalizedString(@"Quit", nil) 
												target: self 
											  selector: @selector(returnToMain:)];
	
	CCSprite *node = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"menu.png"]];	
	
	CCMenuItemSprite *sprite = [CCMenuItemSprite itemFromNormalSprite: node 
												   selectedSprite: node 
														   target: self 
														 selector: @selector(toggleMenu:)];
	
	[sprite setScale:1.6f];
	
	// Detect current pause/resume state
		
	if (!self.isFighting){
		[startStop setSelectedIndex:1];
	}
	
	[[item0 label] setColor:ccc3(10, 10, 10)];
	[startStop setColor:ccc3(10, 10, 200)];
	[[item1 label] setColor:ccc3(255, 10, 10)];
	[[item2 label] setColor:ccc3(255, 255, 255)];
	
	self.menu = [CCMenu menuWithItems: item0, startStop, item1, item2, sprite, nil];
	
	int offset = 210;
	
	// Limit menu for challenge
	if (self.typeOfBattleground == kBattlegroundChallenge) {
		[menu removeChild:item0 cleanup:YES];
		[menu removeChild:item1 cleanup:YES];
		offset = 110;
	}
	
	[menu alignItemsHorizontallyWithPadding:16];
	[menu setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width-offset,-15)];
	[self addChild: menu z:9001 tag:kBattlegroundMenu];
	
}

// Show menu
- (void) showMenu {
	[menu runAction:[CCMoveTo actionWithDuration:0.3f position:ccp([menu position].x,15)]];
}

// Hide menu
- (void) hideMenu {
	[menu runAction:[CCMoveTo actionWithDuration:0.3f position:ccp([menu position].x,-15)]];
}

// Toggle menu between shown/hidden
- (void) toggleMenu: (id) data {
	
	if ([self getChildByTag:kUnitSelection] != nil){
		return;
	}
	
	// Check if menu is in motion already, fixes bug moving menu off screen
	if ([menu numberOfRunningActions] > 0) {
		return;
	}
		
	if ([menu position].y == 15) {
		[self hideMenu];
	} else {
		[self showMenu];
	}
	
	
}


-(void) showUnitSelection: (id) sender{
	// Detect if unit selection is already shown
	if ([self getChildByTag:kUnitSelection] == nil){
		[self hideMenu];
		//[self toggleMenu:sender];
		[self addChild:[UnitSelectionMenu node] z:INT_MAX tag:kUnitSelection];
	}
	
}

-(void) loadDashboard: (id) sender{
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if ((orientation ==  UIDeviceOrientationLandscapeLeft) || (orientation ==  UIDeviceOrientationLandscapeRight)) {
		[OpenFeint setDashboardOrientation:(UIInterfaceOrientation)[[UIDevice currentDevice] orientation]];
	}
	
	[OpenFeint launchDashboard];
	
}

- (void) startStop: (id) sender {
	
	[self toggleMenu:sender];
	
	[self toggleBattle];
	
	/*if ([sender selectedIndex] == 1){
		[self pauseBattle];
	} else if ([sender selectedIndex] == 0) {
		[self resumeBattle];
	}*/
	
}

- (void) toggleBattle {
	
	if (self.isFighting) {
		[self unschedule:@selector(fightBattle)];
		self.isFighting = NO;
		self.wasFighting = NO;
	} else {
		[self schedule:@selector(fightBattle)];
		self.isFighting = YES;
		self.wasFighting = YES;
	}
	
}


- (void) resumeBattle {
	
	[self schedule:@selector(fightBattle)];
	self.isFighting = YES;
	
}

- (void) pauseBattle {
	
	[self unschedule:@selector(fightBattle)];
	self.isFighting = NO;
	
}

#pragma mark Synchronization

- (void) step: (ccTime) delta {
	
	int steps = 4;
	CGFloat dt = delta/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
	
	cpSpaceHashEach(space->activeShapes, (cpSpaceHashIterator)eachShape, nil);
	cpSpaceHashEach(space->staticShapes, (cpSpaceHashIterator)eachShape, nil);
	
	/*if (self.shouldDisplayMovementBox) {
		
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		
		int base = 10;
		int a = 120;
		int b = 80;
		int y = 320-base-base-b;
		
		CGPoint points[4] = {cpv(base+y, base), cpv(base+y, a+base), cpv(b+base+y, a+base), cpv(b+base+y, base)};
		
		ccDrawPoly(points, 4, YES);
		
		int base3 = 15+15*self.offsetUnits.x/480;
		int base2 = 15+15*self.offsetUnits.y/320;
		int a2 = 30;0+30*self.offsetUnits.x/480;
		int b2 = 20;0+20*self.offsetUnits.y/320;
		int y2 = 320-base2-base2-b2;
		
		CGPoint points2[4] = {cpv(base3+y2, base2), cpv(base3+y2, a2+base2), cpv(b2+base3+y2, a2+base2), cpv(b2+base3+y2, base2)};
		
		ccDrawPoly(points2, 4, YES);
		
		NSLog(@"X: %f - Y: %f", self.offsetUnits.x, self.offsetUnits.y);
	}*/
	
}

// Synchronize graphics engine and physics engine
static void eachShape(void *ptr, void* unused) {
	
	cpShape *shape = (cpShape *) ptr;
	
	Unit *sprite = (Unit *)shape->data;
	
	if( sprite ) {
		cpBody *body = shape->body;
		if (body){
			[sprite setPosition: cpBodyGetPos(body)];
			cpBodySetAngle(body, CC_DEGREES_TO_RADIANS(-sprite.rotation));
		}
	}
	
}

- (void) checkEmptyFaction{
	
	if ([unitSystem isAnyFactionEmpty]){
		
		if (unitSystem.unitsEnemy > 30) {
			
			[self addUnitWithType:kUnitTypeTankHeavy faction:kFactionFriend];
			
			for (int i = 0; i < 4; i++) {
				[self addUnitWithType:kUnitTypeTankLight faction:kFactionFriend];
			}
			
			for (int i = 0; i < 10; i++) {
				[self addUnitWithType:kUnitTypeSoldierArmored faction:kFactionFriend];
			}
			
		} else if (unitSystem.unitsFriendly > 30) {
			
			[self addUnitWithType:kUnitTypeTankHeavy faction:kFactionEnemy];
			
			for (int i = 0; i < 4; i++) {
				[self addUnitWithType:kUnitTypeTankLight faction:kFactionEnemy];
			}
			
			for (int i = 0; i < 10; i++) {
				[self addUnitWithType:kUnitTypeSoldierArmored faction:kFactionEnemy];
			}
			
		} else {
			
			[self spawnRandomUnits];
			
		}
		
	}
}

- (void) unitRepair{
	
	[unitSystem healAllUnits];
	
}



- (void) returnToMain: (id) sender {
	
	UIAlertView *infoMessage = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Return to Main Menu?", nil) 
														  message: nil
														 delegate: self 
												cancelButtonTitle: NSLocalizedString(@"Cancel" , nil)
												otherButtonTitles: NSLocalizedString(@"Return", nil), NSLocalizedString(@"Save and Return", nil), nil];
	[[CCDirector sharedDirector] pause];
	[infoMessage show];
	[infoMessage autorelease];
	
}

- (void) saveKillCountFromSession {
	
	long previousKills = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"totalKills"] longValue];
	
	NSNumber *totalKills = [NSNumber numberWithLong:self.kills + previousKills];
	
	[[NSUserDefaults standardUserDefaults] setObject:totalKills forKey:@"totalKills"];
	
	NSLog(@"kills: %lu - totalkills: %lu", self.kills, [totalKills longValue]);
	
	[self checkKillCountAchievement];
	
}

- (void) checkKillCountAchievement {
	
	long previousKills = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"totalKills"] longValue];
	
	long totalKills = self.kills + previousKills;
	
	// check each achievement individually
	// don't want a condition like having 500 kills but not 10 from being offline
	if (totalKills >= 10l) {
		[OFAchievementService unlockAchievement:@"76083"]; 
	}
	if (totalKills >= 100l) {
		[OFAchievementService unlockAchievement:@"76093"];
	}
	if (totalKills >= 500l) {
		[OFAchievementService unlockAchievement:@"76103"];
	}
	if (totalKills >= 1000l) {
		[OFAchievementService unlockAchievement:@"76113"];
	}
	if (totalKills >= 5000l) {
		[OFAchievementService unlockAchievement:@"76123"];
	}
}

- (CGPoint) center {
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	return CGPointMake(winSize.width/2, winSize.height/2);
	
}

- (void) cleanAllBullets {
	
	for (CCNode *bullet in self.children) {
		if ([bullet isKindOfClass:[Bullet class]]) {
			[self removeBullet:bullet];
		}
	}
	
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	[[CCDirector sharedDirector] resume];
	
	if (buttonIndex != alertView.cancelButtonIndex) {
		
		if ([alertView.title isEqualToString: NSLocalizedString(@"Return to Main Menu?", nil) ]) {
			// Exit confirm
			
			if (buttonIndex == 2) {
				// Save before exiting
				[self saveBattlegroundToFile:nil];
			}
			
			//cpSpaceRemoveCollisionPairFunc(space, kCollisionTypeBullet, kCollisionTypeUnit);
			cpSpaceRemoveCollisionHandler(space, kCollisionTypeBullet, kCollisionTypeUnit);
			
			[unitSystem clearAllUnits];
			
			[self saveKillCountFromSession];
			
			// wtf was this? why did i even do this?
			// it's for the transitions, has to be a better method to do this
			switch (self.typeOfBattleground) {
					
					[[CCDirector sharedDirector] resume];

				case kBattlegroundFreeMode:
					[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:1 scene:[MainMenuLayer node]]];
					break;
				case kBattlegroundCampaign:
					[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInB transitionWithDuration:1 scene:[MainMenuLayer node]]];
					break;
				case kBattlegroundChallenge:
					[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInB transitionWithDuration:1 scene:[MainMenuLayer node]]];
					break;
			}
			
		} else {
			// Unit clear confirm
			[unitSystem clearAllUnits];

		}
		
		
	}
	
}



@end


