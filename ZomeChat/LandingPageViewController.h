//
//  LandingPageViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 12/18/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MainViewController.h"

@interface LandingPageViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UILabel *msgCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *nearbyUserCountLabel;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *themeListButton;
@property (weak, nonatomic) IBOutlet UIButton *messageBoardButton;

-(void) setUserCount:(NSString *)userCount msgCount:(NSString *)msgCount andRoomCount:(NSString *)roomCount;
- (void) updateRoomCount:(NSString *) roomCount;
- (void) updateMessageCount:(NSString *) msgCount;

@end
