//  Copyright 2009-2010 Aurora Feint, Inc.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  	http://www.apache.org/licenses/LICENSE-2.0
//  	
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "OFDependencies.h"
#import "OFHighScoreController.h"
#import "OFResourceControllerMap.h"
#import "OFHighScore.h"
#import "OFHighScoreService.h"
#import "OFLeaderboard.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFUser.h"
#import "OFProfileController.h"
#import "OFControllerLoader.h"
#import "OpenFeint.h"
#import "OpenFeint+Private.h"
#import "OFTabbedPageHeaderController.h"
#import "OFDefaultLeadingCell.h"
#import "OFTableSectionDescription.h"
#import "OFGameProfilePageInfo.h"
#import "OpenFeint+UserOptions.h"
#import "OFPlainMessageTrailingCell.h"
#import "OFImageLoader.h"
#import "OFHighScoreMapViewController.h"
#import "OFDelegatesContainer.h"
#import "OFFramedNavigationController.h"

@interface OFHighScoreController() 

//delegates for main load
-(void)onLoadFinished;
-(void)onLoadFailed;

//delegates for sub loads
-(void)onFriendsLoadSuccess:(OFPaginatedSeries*)resources;
-(void)onGlobalLoadSuccess:(OFPaginatedSeries*)resources;

@property (nonatomic, retain) NSString* noDataFoundMessage;
@property (nonatomic, retain) OFPaginatedSeries* friendResources;  
@property (nonatomic, retain) OFPaginatedSeries* globalResources; 
@property (nonatomic) NSUInteger timeScope;
@end

@implementation OFHighScoreController

@synthesize leaderboard;
@synthesize noDataFoundMessage;
@synthesize gameProfileInfo;
@synthesize friendResources;
@synthesize globalResources;
@synthesize timeScope;


-(void)clickedMap 
{
	OFHighScoreMapViewController* mapViewController = (OFHighScoreMapViewController*)OFControllerLoader::load(@"Mapping");
	[mapViewController setLeaderboard:leaderboard.resourceId];
	[mapViewController getScores];
    OFFramedNavigationController* nav = [[OFFramedNavigationController alloc] initWithRootViewController:mapViewController];    
    [[OpenFeint getRootController] presentModalViewController:nav animated:YES];
    [nav release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = leaderboard.name;
    
	OFUserDistanceUnitType unit = [OpenFeint userDistanceUnit];	
	if ([OpenFeint isOnline] && unit != kDistanceUnitNotAllowed)
	{
		UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[OFImageLoader loadImage:@"OFMapButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(clickedMap)];
		self.navigationItem.rightBarButtonItem = button;
	}
	
	if (![OpenFeint isOnline])
	{
		self.noDataFoundMessage = [NSString stringWithFormat:OFLOCALSTRING(@"All of your high scores for %@ will show up here. You have not posted any yet."), leaderboard.name];
	}
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFHighScore class], @"HighScore");
}

- (OFService*)getService
{
	return [OFHighScoreService sharedInstance];
}

-(void)setTimeScopingAll 
{
	self.noDataFoundMessage = [NSString stringWithFormat:OFLOCALSTRING(@"No one has posted high scores for %@ yet."), leaderboard.name];
	[self showLoadingScreen];    
    self.timeScope = 0;
    [self doIndexActionOnSuccess:[self getOnSuccessDelegate] onFailure:[self getOnFailureDelegate]];
}

-(void)setTimeScopingDay
{
	self.noDataFoundMessage = [NSString stringWithFormat:OFLOCALSTRING(@"No one has posted high scores for %@ yet."), leaderboard.name];
	[self showLoadingScreen];    
    self.timeScope = 1;
    [self doIndexActionOnSuccess:[self getOnSuccessDelegate] onFailure:[self getOnFailureDelegate]];
}

-(void)setTimeScopingWeek
{
	self.noDataFoundMessage = [NSString stringWithFormat:OFLOCALSTRING(@"No one has posted high scores for %@ yet."), leaderboard.name];
	[self showLoadingScreen];    
    self.timeScope = 7;
    [self doIndexActionOnSuccess:[self getOnSuccessDelegate] onFailure:[self getOnFailureDelegate]];
}

-(void)nullyMethod
{
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	if ([OpenFeint isOnline])
	{
        self.friendResources = nil;
        self.globalResources = nil;
        
        [OFHighScoreService getPage:1 
                     forLeaderboard:leaderboard.resourceId 
                   comparedToUserId:[self getPageComparisonUser].resourceId
                        friendsOnly:YES 
                           silently:NO
                          timeScope:self.timeScope
                          onSuccess:OFDelegate(self, @selector(onFriendsLoadSuccess:))
                          onFailure:OFDelegate(self, @selector(onLoadFailed))];
        
        [OFHighScoreService getPage:1 
                     forLeaderboard:leaderboard.resourceId 
                   comparedToUserId:[self getPageComparisonUser].resourceId
                        friendsOnly:NO 
                           silently:NO
                          timeScope:self.timeScope
                          onSuccess:OFDelegate(self, @selector(onGlobalLoadSuccess:))
                          onFailure:OFDelegate(self, @selector(onLoadFailed))];
	} else {
		[OFHighScoreService getLocalHighScores:leaderboard.resourceId onSuccess:success onFailure:failure];
	}
}


-(void)onLoadFinished 
{
    [self hideLoadingScreen];
    OFPaginatedSeries* combined = [OFPaginatedSeries paginatedSeriesFromSeries:self.globalResources];    
    
	if ([friendResources.objects count] > 1)
	{
		OFTableSectionDescription* friendsDesc = [OFTableSectionDescription new];
		friendsDesc.title = OFLOCALSTRING(@"Friends");
		friendsDesc.page = [OFPaginatedSeries paginatedSeriesFromArray:self.friendResources.objects];
		[combined.objects insertObject:friendsDesc atIndex:1];
		[friendsDesc release];
	}
    
    [super _onDataLoadedWrapper:combined isIncremental:NO];
}

-(void)onLoadFailed 
{
    [self hideLoadingScreen];
    self.friendResources = nil;
    self.globalResources = nil;
    //hide loading bar
}

//delegates for sub loads
-(void)onFriendsLoadSuccess:(OFPaginatedSeries*)resources 
{
    self.friendResources = resources;
    if(self.globalResources) [self onLoadFinished];
}

-(void)onGlobalLoadSuccess:(OFPaginatedSeries*)resources 
{
    self.globalResources = resources;
    if(self.friendResources) [self onLoadFinished];
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	OFTabbedPageHeaderController* header = (OFTabbedPageHeaderController*)tableHeader;
	header.callbackTarget = self;
	if ([OpenFeint isOnline])
	{
		if (![OpenFeint isInLandscapeMode])
		{
			header.tabBar.textAlignment = UITextAlignmentLeft;
			header.tabBar.labelPadding = CGRectMake(28, 0, 0, 0);
		}

		[header addTab:OFLOCALSTRING(@"All Time") andSelectedCallback:@selector(setTimeScopingAll)];
		[header addTab:OFLOCALSTRING(@"Today") andSelectedCallback:@selector(setTimeScopingDay)];
		[header addTab:OFLOCALSTRING(@"This week") andSelectedCallback:@selector(setTimeScopingWeek)];
	} else {
	    [header addTab:OFLOCALSTRING(@"My Scores") andSelectedCallback:@selector(nullyMethod)];
	}
}

-(bool)allowPagination 
{
    return NO;
}

- (bool)usePlainTableSectionHeaders
{
	return true;
}

- (NSString*)getTableHeaderControllerName
{
	return @"TabbedPageHeader";
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFHighScore class]] && [OpenFeint isOnline])
	{
		OFHighScore* highScoreResource = (OFHighScore*)cellResource;
        if(highScoreResource.user)
			[OFProfileController showProfileForUser:highScoreResource.user];
	}
}

- (NSString*)getNoDataFoundMessage
{
	return noDataFoundMessage;      
}

- (void)dealloc
{
    self.globalResources = nil;
    self.friendResources = nil;
    
	self.noDataFoundMessage = nil;
	self.leaderboard = nil;
	self.gameProfileInfo = nil;
	[super dealloc];
}

- (void)downloadBlobForHighScore:(OFHighScore*)highScore
{
	if ([highScore hasBlob])
	{
		[self showLoadingScreen];
		OFDelegate success(self, @selector(onBlobDownloadedForHighScore:));
		OFDelegate failure(self, @selector(onBlobFailedDownloading));
		[OFHighScoreService downloadBlobForHighScore:highScore onSuccess:success onFailure:failure];
	}
}

- (void)onBlobDownloadedForHighScore:(OFHighScore*)highScore
{
	[self hideLoadingScreen];
	id ofDelegate = [OpenFeint getDelegate];
	OF_OPTIONALLY_INVOKE_DELEGATE_WITH_TWO_PARAMETERS(ofDelegate, userDownloadedBlob:forHighScore:, (highScore.blob), highScore);
}

- (void)onBlobFailedDownloading
{
	[self hideLoadingScreen];
	[[[[UIAlertView alloc] 
	   initWithTitle:OFLOCALSTRING(@"Error!") 
	   message:OFLOCALSTRING(@"There was a problem downloading the data for this high score. Please try again later.") 
	   delegate:nil 
	   cancelButtonTitle:OFLOCALSTRING(@"OK") 
	   otherButtonTitles:nil] autorelease] show];
}

@end
