//
//  Inkspot.h
//  DrawBattlefield
//
//  Created by James Washburn on 9/30/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Extends Unit to add resource specific functionality

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "factions.h"
#import "Unit.h"

@interface Inkspot : Unit {

}

+ (Inkspot *) inkspotWithPosition:(CGPoint)position;

+ (Inkspot *) inkspotFromData:(NSMutableDictionary *)savedData;

@end
