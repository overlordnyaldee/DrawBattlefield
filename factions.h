//
//  Faction.h
//  DrawBattlefield
//
//  Created by James Washburn on 9/15/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Various values, settings, etc

#define AMARandom(s,e) s+(int)(e*random() / ( RAND_MAX + s ) )

#ifndef __IPHONE_3_2	// if iPhoneOS is 3.2 or greater then __IPHONE_3_2 will be defined

typedef enum {
    UIUserInterfaceIdiomPhone,           // iPhone and iPod touch style UI
    UIUserInterfaceIdiomPad,             // iPad style UI
} UIUserInterfaceIdiom;

#define UI_USER_INTERFACE_IDIOM() UIUserInterfaceIdiomPhone

#endif // ifndef __IPHONE_3_2

#define DrawBattlefieldSavedBattlegroundVersion 1
#define DrawBattlefieldSavedUnitDataVersion 1
#define kUnitZ 1
#define kFileName @"/data.plist"

#define kZoomMax 1.0
#define kZoomMin 0.5

#define kCollisionTypeBullet 10
#define kCollisionTypeUnit 20

#define kBattlegroundCampaign 1
#define kBattlegroundFreeMode 2
#define kBattlegroundMainMenuBackground 3
#define kBattlegroundChallenge 4

#define kFileFormatDataOffset 4


#define kFactionFriend 1
#define kFactionEnemy 2
#define kFactionNeutral 0

#define kFactorySizeSmall 1
#define kFactorySizeMedium 2
#define kFactorySizeLarge 4

#define kUnitTypeInkspot -2
#define kUnitTypeFactory -1

#define kUnitTypeSoldierArmored 1
#define kUnitTypeSoldierOfficer 2

#define kUnitTypeTurretLight 3
#define kUnitTypeTurretHeavy 4

#define kUnitTypeTankLight 5
#define kUnitTypeTankHeavy 6

#define kUnitTypeSniper 7
#define kUnitTypePoweredArmor 8

#define kUnitTypeSoldier 9
#define kUnitTypeSoldierRocket 10

#define kUnitTypeShield 11
#define kUnitTypeSoldierDrill 12


#define kBattlegroundChallengeTypeSniper @"sniperchallenge"
#define kBattlegroundChallengeTypeArmored @"armoredchallenge"
#define kBattlegroundChallengeTypeTurret @"turretchallenge"
#define kBattlegroundChallengeTypeTank1 @"tankchallenge"
#define kBattlegroundChallengeTypeTank2 @"tankchallenge2"