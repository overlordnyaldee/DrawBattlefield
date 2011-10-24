//
//  UnitCreation.m
//  DrawBattlefield
//
//  Created by James Washburn on 11/12/09.
//  Copyright 2009 Annunaki Systems. All rights reserved.
//

#import "UnitCreation.h"
#import "cocos2d.h"
#import "factions.h"
 
@implementation UnitCreation

CGImageRef UIGetScreenImage();

- (UIImage *)takeScreenshot {
	return [UIImage imageWithCGImage:UIGetScreenImage()];
}

/*- (void)takeScreenshot {
	UIWindow *theScreen = [[UIApplication sharedApplication].windows objectAtIndex:0];
	UIGraphicsBeginImageContext(theScreen.frame.size);
	CALayer *layer = [theScreen layer];
	[layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//[self doSomethingWith:screenshot];
}

- (UIImage *)captureView:(UIView *)view { 
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	
	UIGraphicsBeginImageContext(screenRect.size);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext(); 
	[[UIColor blackColor] set]; 
	CGContextFillRect(ctx, screenRect);
	
	[view.layer renderInContext:ctx];
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return newImage; 
}

- (UIImage *) screenCapture {
	//UIGraphicsBeginImageContext([[Director sharedDirector] winSize]);
	//[[Director sharedDirector] AT
	//[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	//[[[(DrawBattlefieldAppDelegate *)[UIApplication sharedApplication] delegate] window]
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	//UIGraphicsEndImageContext();
	
	return viewImage;
}*/

- (void) writeImage:(UIImage *)image ToFile:(NSString *) imagePath {
	
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
	
	[imageData writeToFile:imagePath atomically:YES];
	
}

- (UIImage *) restoreImageFromFile:(NSString *) imagePath {
	
	return [UIImage imageWithContentsOfFile:imagePath];
	
}

+ (NSString *) savedUnitDataFileWithName:(NSString *) name{
		
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	return [documentsDirectory stringByAppendingString:name];
}

// Save battle to file
- (BOOL) saveUnitDataToFile:(NSString *)file {
	
	if (!file) {
		
	} else {

	}
	
	NSMutableArray *savedData = [NSMutableArray arrayWithCapacity:5];
	
	[savedData addObject:@"DrawBattlefield Saved Unit Data"];
	[savedData addObject:[NSNumber numberWithInt:DrawBattlefieldSavedBattlegroundVersion]];
	
	return [savedData writeToFile: file atomically:YES];
}

- (BOOL) readUnitDataFromFile:(NSString *)file {
	
	NSLog(@"looking for saved");
	
	// Load from plist
	
	NSArray *savedData;
	
	if (file) {
		savedData = [NSArray arrayWithContentsOfFile:file];
	} else {
		//savedData = [NSArray arrayWithContentsOfFile:[Battleground defaultSavedDataFile]];
		savedData = nil;
	}
	
	// Detect if saved exists
	if (savedData != nil){
		
		NSLog(@"file found");
		
		// version check
		if ([[savedData objectAtIndex:1] intValue] == DrawBattlefieldSavedBattlegroundVersion){
			
			NSLog(@"version correct, loading");
			
			int typeSaved = [[savedData objectAtIndex:2] intValue];
			typeSaved = 2;
			return TRUE;
			
		} else {
			
			NSLog(@"version %d incorrect, deleting", [[savedData objectAtIndex:1] intValue]);
			
			//[[NSFileManager defaultManager] removeItemAtPath:file error:NULL];
			
			return FALSE;
		}
		
	} else {
		NSLog(@"not found");
		
		return FALSE;
		
	}
	
}

UIImage *scaleAndRotateImage(UIImage *image)  
{  
    int kMaxResolution = 320; // Or whatever  
	
    CGImageRef imgRef = image.CGImage;  
	
    CGFloat width = CGImageGetWidth(imgRef);  
    CGFloat height = CGImageGetHeight(imgRef);  
	
    CGAffineTransform transform = CGAffineTransformIdentity;  
    CGRect bounds = CGRectMake(0, 0, width, height);  
    if (width > kMaxResolution || height > kMaxResolution) {  
        CGFloat ratio = width/height;  
        if (ratio > 1) {  
            bounds.size.width = kMaxResolution;  
            bounds.size.height = bounds.size.width / ratio;  
        }  
        else {  
            bounds.size.height = kMaxResolution;  
            bounds.size.width = bounds.size.height * ratio;  
        }  
    }  
	
    CGFloat scaleRatio = bounds.size.width / width;  
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
    CGFloat boundHeight;  
    UIImageOrientation orient = image.imageOrientation;  
    switch(orient) {  
			
        case UIImageOrientationUp: //EXIF = 1  
            transform = CGAffineTransformIdentity;  
            break;  
			
        case UIImageOrientationUpMirrored: //EXIF = 2  
            transform = CGAffineTransformMakeTranslation(imageSize.width, (CGFloat)0.0);  
            transform = CGAffineTransformScale(transform, (CGFloat)-1.0, (CGFloat)1.0);  
            break;  
			
        case UIImageOrientationDown: //EXIF = 3  
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);  
            transform = CGAffineTransformRotate(transform, (CGFloat)M_PI);  
            break;  
			
        case UIImageOrientationDownMirrored: //EXIF = 4  
            transform = CGAffineTransformMakeTranslation((CGFloat)0.0, imageSize.height);  
            transform = CGAffineTransformScale(transform, (CGFloat)1.0, (CGFloat)-1.0);  
            break;  
			
        case UIImageOrientationLeftMirrored: //EXIF = 5  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);  
            transform = CGAffineTransformScale(transform, (CGFloat)-1.0, (CGFloat)1.0);  
            transform = CGAffineTransformRotate(transform, (CGFloat) (3.0 * M_PI / 2.0));  
            break;  
			
        case UIImageOrientationLeft: //EXIF = 6  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation((CGFloat)0.0, imageSize.width);  
            transform = CGAffineTransformRotate(transform, (CGFloat)(3.0 * M_PI / 2.0));  
            break;  
			
        case UIImageOrientationRightMirrored: //EXIF = 7  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeScale((CGFloat)-1.0, (CGFloat)1.0);  
            transform = CGAffineTransformRotate(transform, (CGFloat)(M_PI / 2.0));  
            break;  
			
        case UIImageOrientationRight: //EXIF = 8  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, (CGFloat)0.0);  
            transform = CGAffineTransformRotate(transform, (CGFloat)(M_PI / 2.0));  
            break;  
			
        default:  
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];  
			
    }  
	
    UIGraphicsBeginImageContext(bounds.size);  
	
    CGContextRef context = UIGraphicsGetCurrentContext();  
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {  
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);  
        CGContextTranslateCTM(context, -height, 0);  
    }  
    else {  
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);  
        CGContextTranslateCTM(context, 0, -height);  
    }  
	
    CGContextConcatCTM(context, transform);  
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);  
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
	
    return imageCopy;  
}  


@end
