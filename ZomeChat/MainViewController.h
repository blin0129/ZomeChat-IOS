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
@property NSNumber *postCount;
@property NSNumber *userCount;
@property (nonatomic) CLLocation *currentLocation;
@property NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *defaultRoomList;
@property (strong, nonatomic) NSMutableArray *customRoomList;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *myLocationMarker;


- (float) getLatitude;
- (float) getLongitude;

- (void) requestProfile;
- (void) requestChatroomList;
- (void) requestMsgboardData;
- (void) requestLandingPageInfo;
- (void) requestEnterChatroom: (NSString*) roomKey;
- (void) requestSendMessage: (NSString *)message inRoom: (NSString *)roomKey;
- (void) requestSendImage: (NSString *)image inRoom:(NSString *)roomKey;
- (void) requestLeaveChatroom: (NSString *)roomKey;
- (void) requestCreateNewRoom: (NSString *)roomName;
- (void) requestCreateNewMessage: (NSString *) messageContent withImage:(NSString *) imageString;
- (void) requestProfileUpdate: (NSString *)image;
- (void) requestUsernameChange: (NSString *)newName;
- (void) requestLocationUpdate;
- (void) requestPostComment: (NSString *)comment onFeed: (NSString *)feedId;
- (void) requestLikeFeed: (NSString *)feedId;
- (void) requestFeedDetail: (NSString *)feedId;


- (void) updateLocationOnMap;
- (void) cleanAllMarkerFromMap;
- (void) addMapMarkerWithLongitude: (float)lng latitude:(float)lat roomName:(NSString *)note;

- (void)toLandingPage;
- (void)toChatPage;
- (void)toMessagePage;

@end
