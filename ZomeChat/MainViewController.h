//
//  MainViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "LoginViewController.h"

@interface MainViewController : UITabBarController<SocketIODelegate>
{
    SocketIO *socketIO;
}

@property (atomic) SocketIO *socketIO;
@property NSNumber *themeCount;
@property NSNumber *messageCount;
@property NSNumber *nearbyUserCount;
@property (nonatomic) CLLocation *currentLocation;
@property NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *themeList;

-(float) getLatitude;
-(float) getLongitude;

-(void) requestProfile;
-(void) requestThemeList;
-(void) requestMsgboardData;
-(void) requestLandingPageInfo;
-(void) requestRoom: (NSDictionary*) requestRoomData;
-(void) requestSendMessage: (NSString *)message inRoom: (NSString *)roomKey;
-(void) requestSendImage: (NSString *)image inRoom:(NSString *)roomKey;
-(void) requestLeaveRoom: (NSString *)roomKey;
-(void) requestCreatingNewRoom: (NSString *)roomName;
-(void) requestCreateNewMessage: (NSString *) messageContent;
- (void) requestProfileUpdate: (NSString *)image;

-(void)toLandingPage;
-(void)toChatPage;
-(void)toMessagePage;

@end
