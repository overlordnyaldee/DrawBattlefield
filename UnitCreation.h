//
//  UnitCreation.h
//  DrawBattlefield
//
//  Created by James Washburn on 11/12/09.
//  Copyright 2009 Amaranthine Corporation. All rights reserved.
//
// Unit creation, will eventually allow users to create their own units

#import <Foundation/Foundation.h>


@interface UnitCreation : NSObject {

}

- (UIImage *)takeScreenshot;

- (void) writeImage:(UIImage *)image ToFile:(NSString *) imagePath;
- (UIImage *) restoreImageFromFile:(NSString *) imagePath;

+ (NSString *) savedUnitDataFileWithName:(NSString *) name;

- (BOOL) saveUnitDataToFile:(NSString *)file;
- (BOOL) readUnitDataFromFile:(NSString *)file;

@end
