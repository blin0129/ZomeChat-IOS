//
//  MainViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "MainViewController.h"
#import "Room.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize socketIO;
@synthesize timer;
@synthesize mapView;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        APPDELEGATE.mainVC = self;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadMap];
    socketIO = APPDELEGATE.socketIO;
    socketIO.delegate = self;
    
    if([CLLocationManager locationServicesEnabled]){
        _currentLocation = APPDELEGATE.locationManager.location;
    }
    self.tabBar.barTintColor = [UIColor darkGrayColor];
}

- (void) loadMap
{
    double lat = APPDELEGATE.lat.doubleValue;
    double lng = APPDELEGATE.lng.doubleValue;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lng
                                                                 zoom:14];
    CGRect mapSize = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width/3);
    mapView = [GMSMapView mapWithFrame:mapSize camera:camera];
    //    mapView.myLocationEnabled = YES;
    //    [mapContainer addSubview:mapView];
    
    //    // Creates a marker in the center of the map.
    self.myLocationMarker = [[GMSMarker alloc] init];
    self.myLocationMarker.position = CLLocationCoordinate2DMake(lat, lng);
    self.myLocationMarker.title = @"Your Location";
    self.myLocationMarker.map = mapView;
}

- (void) updateLocationOnMap
{
    CLLocationCoordinate2D newLoc = CLLocationCoordinate2DMake(APPDELEGATE.lat.doubleValue,APPDELEGATE.lng.doubleValue);
    [mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:newLoc]];
    self.myLocationMarker.position = CLLocationCoordinate2DMake(APPDELEGATE.lat.doubleValue, APPDELEGATE.lng.doubleValue);
}

- (void) cleanAllMarkerFromMap
{
    [mapView clear];
    self.myLocationMarker.map = mapView;
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(APPDELEGATE.lat.doubleValue, APPDELEGATE.lng.doubleValue);
//    marker.title = @"Your Location";
//    marker.map = mapView;
}

- (void) addMapMarkerWithLongitude: (float)lng latitude:(float)lat roomName:(NSString *)note
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(lat, lng);
    marker.icon = [UIImage imageNamed:@"circle_marker"];
    marker.title = note;
    marker.map = mapView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(float) getLongitude
{
    return _currentLocation.coordinate.longitude;
}

-(float) getLatitude
{
    return _currentLocation.coordinate.latitude;
}

- (void) toLandingPage
{
    self.selectedViewController = [self.viewControllers objectAtIndex:0];
}

- (void) toChatPage
{
    self.selectedViewController = [self.viewControllers objectAtIndex:1];
}

- (void) toMessagePage
{
    self.selectedViewController = [self.viewControllers objectAtIndex:2];
}

-(void) requestEnterChatroom: (NSString *) roomKey
{
    NSDictionary* requestEnterRoomData = @{@"uid" : APPDELEGATE.uid,
                                           @"roomKey" : roomKey,
                                           };
        [socketIO sendEvent:@"requestEnterChatroom" withData:requestEnterRoomData];
}

-(void) requestCreateNewMessage: (NSString *) messageContent withImage:(NSString *)imageString
{
    NSDictionary* requestCreatingMessageData = @{@"uid" : APPDELEGATE.uid,
                                              @"lng" : APPDELEGATE.lng,
                                              @"lat" : APPDELEGATE.lat,
                                              @"content" : messageContent,
                                              @"image" : imageString
                                              };
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastMessageCreatedTime"];
    [socketIO sendEvent:@"requestCreateMessage" withData:requestCreatingMessageData];
}

-(void) requestMsgboardData
{
    NSDictionary* requestMessageboardData = @{@"uid" : APPDELEGATE.uid,
                                              @"lng" : APPDELEGATE.lng,
                                              @"lat" : APPDELEGATE.lat
                                              };
    [socketIO sendEvent:@"requestMessageboard" withData:requestMessageboardData];
}


- (void) requestCreateNewRoom: (NSString *)roomName
{
    NSDictionary* requestCreatingRoomData = @{@"uid" : APPDELEGATE.uid,
                                           @"roomName" : roomName
                                           };
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastRoomCreatedTime"];
    [socketIO sendEvent:@"requestCreateNewRoom" withData:requestCreatingRoomData];
}

- (void) requestChatroomList
{
    NSDictionary* requestThemeListData = @{@"uid" : APPDELEGATE.uid};
    [socketIO sendEvent:@"requestChatroomList" withData:requestThemeListData];
}

- (void) requestProfile
{
    NSDictionary* requestProfileData = @{@"uid" : APPDELEGATE.uid};
    [socketIO sendEvent:@"requestProfile" withData:requestProfileData];
}

- (void) requestUsernameChange: (NSString *)newName
{
    NSDictionary* requestUsernameChangeData = @{@"uid" : APPDELEGATE.uid,
                                              @"username" : newName
                                              };
    [socketIO sendEvent:@"requestUsernameChange" withData:requestUsernameChangeData];
}

- (void) requestLocationUpdate
{
    NSDictionary* requestLocationUpdateData = @{@"uid" : APPDELEGATE.uid,
                                               @"lat" : APPDELEGATE.lat,
                                               @"lng" : APPDELEGATE.lng
                                               };
    [socketIO sendEvent:@"requestLocationUpdate" withData:requestLocationUpdateData];
}

- (void) requestSendMessage: (NSString *)message inRoom: (NSString *)roomKey
{
    NSDictionary* requestSendMessageData = @{@"uid" : APPDELEGATE.uid,
                                             @"message" : message,
                                             @"roomKey" : roomKey
                                             };
    [socketIO sendEvent:@"sendChatroomMessage" withData:requestSendMessageData];
}

- (void) requestSendImage: (NSString *)image inRoom:(NSString *)roomKey
{
    NSDictionary* requestSendImageData = @{@"uid" : APPDELEGATE.uid,
                                              @"image" : image,
                                              @"roomKey" : roomKey
                                              };
    [socketIO sendEvent:@"chatImage" withData:requestSendImageData];
}

- (void) requestProfileUpdate: (NSString *)image
{
    NSDictionary* requestProfileUpdateData = @{@"uid" : APPDELEGATE.uid,
                                           @"image" : image,
                                           };
    [socketIO sendEvent:@"profileUpdate" withData:requestProfileUpdateData];
}

- (void) requestLeaveChatroom: (NSString *)roomKey
{
    NSDictionary* requestLeaveRoomData = @{@"uid" : APPDELEGATE.uid,
                                             @"roomKey" : roomKey
                                             };
    [socketIO sendEvent:@"requestLeaveChatroom" withData:requestLeaveRoomData];
}

- (void) requestPostComment: (NSString *)comment onFeed: (NSString *)feedId
{
    NSDictionary* requestCommentOnPostData = @{@"uid" : APPDELEGATE.uid,
                                               @"feedId" : feedId,
                                               @"content" : comment
                                               };
    [socketIO sendEvent:@"requestPostComment" withData:requestCommentOnPostData];
}

- (void) requestLikeFeed: (NSString *)feedId
{
    NSDictionary* requestLikePostData = @{@"uid" : APPDELEGATE.uid,
                                          @"feedId" : feedId
                                          };
    [socketIO sendEvent:@"requestLikeFeed" withData:requestLikePostData];
}

- (void) requestFeedDetail: (NSString *)feedId
{
    NSDictionary* requestFeedDetailData = @{@"uid" : APPDELEGATE.uid,
                                          @"feedId" : feedId
                                          };
    [socketIO sendEvent:@"requestFeedDetail" withData:requestFeedDetailData];
}



//** Chatroom Received Methods **//

-(void) receiveChatroomList:(SocketIOPacket *)packet
{
    [APPDELEGATE.chatroomListVC updateChatroomList:packet];
}

- (void) receiveAssignChatroom:(SocketIOPacket *)packet
{
    [APPDELEGATE.chatVC initRoom:packet];
}

-(void) receiveChatroomUserList:(SocketIOPacket *)packet
{
    if(APPDELEGATE.chatVC != nil){
        [APPDELEGATE.chatVC updateChatroomUserList:packet];
    }
}

- (void) receivedChatroomMessage: (SocketIOPacket *)packet
{
    [APPDELEGATE.chatVC receiveMessage:packet];
}


//** Bulletin Board Received Methods **//

- (void) updateMsgboardMessages: (SocketIOPacket *)packet
{
    [APPDELEGATE.msglistVC updateMsgboardMessages:packet];
}

-(void) receiveMyProfile:(SocketIOPacket *)packet
{
    [APPDELEGATE.profileVC receiveMyProfile:packet];
}

-(void) receiveUpdateProfileResponse:(SocketIOPacket *)packet
{
    [APPDELEGATE.profileVC receiveProfileUpdateRespond:packet];
}

-(void) receiveFeedDetail:(SocketIOPacket *)packet
{
    [APPDELEGATE.postVC receiveFeedDetail:packet];
}



//** Other Received Methods **//

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socket.io connected.");
}

//- (void) receiveLocalStats:(SocketIOPacket *)packet
//{
//    //    NSLog(@"Receive landing Pageinfo");
//    NSError *err = nil;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
//    
//    NSString *userCountString = [NSString stringWithFormat:@"%@ nearby users", [dic objectForKey:@"nearbyUserCount"]];
//    NSString *msgCountString = [NSString stringWithFormat:@"%@ msgs", [dic objectForKey:@"messageCount"]];
//    NSString *roomCountString = [NSString stringWithFormat:@"%@ rooms", [dic objectForKey:@"themeRoomsCount"]];
//    [APPDELEGATE.landVC setUserCount:userCountString msgCount:msgCountString andRoomCount:roomCountString];
//}


- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if([packet.name isEqual: @"chatroomList"]){
        [self receiveChatroomList:packet];
    } else if([packet.name isEqual: @"assignChatroom"]){
        [self receiveAssignChatroom:packet];
    } else if([packet.name isEqual: @"chatroomMessage"]){
        [self receivedChatroomMessage:packet];
    } else if([packet.name isEqual: @"messageboardMessages"]){
        [self updateMsgboardMessages:packet];
    } else if([packet.name isEqual:@"updateChatroomUserList"]){
        [self receiveChatroomUserList:packet];
    }  else if([packet.name isEqual:@"myProfile"]){
        [self receiveMyProfile:packet];
    }   else if([packet.name isEqual:@"profileUpdateResponse"]){
        [self receiveUpdateProfileResponse:packet];
    }   else if([packet.name isEqual:@"feedDetail"]){
        [self receiveFeedDetail:packet];
    }

}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"onError() %@", error);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
//    NSLog(@"socket.io disconnected. did error occur? %@", error);
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Server Disconnected"
                                                                  message:@"Plase signin again"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    LoginViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    [self presentViewController:loginView  animated:YES completion:NULL];
    
}

@end
