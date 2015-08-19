//
//  MainViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZomeChat-Swift.h"
#import "LoginViewController.h"

@interface MainViewController : UITabBarController

@property NSNumber *themeCount;
@property NSNumber *postCount;
@property NSNumber *userCount;
@property (nonatomic) CLLocation *currentLocation;
@property NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *defaultRoomList;
@property (strong, nonatomic) NSMutableArray *customRoomList;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *myLocationMarker;
@property (nonatomic, strong) SocketIOClient *socketIO;

@property (strong, nonatomic) NSMutableArray *savedRoomList;


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
- (void) requestReportViolationOf:(NSString *)object withId:(NSString *)objectId andReason:(NSString *)reason;

- (void) requestSavedChatrooms;


- (void) updateLocationOnMap;
- (void) cleanAllMarkerFromMap;
- (void) addMapMarkerWithLongitude: (float)lng latitude:(float)lat roomName:(NSString *)note;

- (void)toLandingPage;
- (void)toChatPage;
- (void)toMessagePage;

@end
