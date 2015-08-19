//
//  MainViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "MainViewController.h"

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
    [self socketOnRecievedData];
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

#pragma mark - Request Actions or Information

-(void) requestEnterChatroom: (NSString *) roomKey
{
    NSDictionary* requestEnterRoomData = @{@"uid" : APPDELEGATE.uid,
                                           @"roomKey" : roomKey,
                                           };
    [socketIO emit:@"requestEnterChatroom" withItems:@[requestEnterRoomData]];
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
    [socketIO emit:@"requestCreateMessage" withItems:@[requestCreatingMessageData]];
}

-(void) requestMsgboardData
{
    NSDictionary* requestMessageboardData = @{@"uid" : APPDELEGATE.uid,
                                              @"lng" : APPDELEGATE.lng,
                                              @"lat" : APPDELEGATE.lat
                                              };
    [socketIO emit:@"requestMessageboard" withItems:@[requestMessageboardData]];
}


- (void) requestCreateNewRoom: (NSString *)roomName
{
    NSDictionary* requestCreatingRoomData = @{@"uid" : APPDELEGATE.uid,
                                           @"roomName" : roomName
                                           };
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastRoomCreatedTime"];
    [socketIO emit:@"requestCreateNewRoom" withItems:@[requestCreatingRoomData]];
}

- (void) requestChatroomList
{
    NSDictionary* requestThemeListData = @{@"uid" : APPDELEGATE.uid};
    [socketIO emit:@"requestChatroomList" withItems:@[requestThemeListData]];
}

- (void) requestProfile
{
    NSDictionary* requestProfileData = @{@"uid" : APPDELEGATE.uid};
    [socketIO emit:@"requestProfile" withItems:@[requestProfileData]];
}

- (void) requestUsernameChange: (NSString *)newName
{
    NSDictionary* requestUsernameChangeData = @{@"uid" : APPDELEGATE.uid,
                                              @"username" : newName
                                              };
    [socketIO emit:@"requestUsernameChange" withItems:@[requestUsernameChangeData]];
}

- (void) requestLocationUpdate
{
    NSDictionary* requestLocationUpdateData = @{@"uid" : APPDELEGATE.uid,
                                               @"lat" : APPDELEGATE.lat,
                                               @"lng" : APPDELEGATE.lng
                                               };
    [socketIO emit:@"requestLocationUpdate" withItems:@[requestLocationUpdateData]];
}

- (void) requestSendMessage: (NSString *)message inRoom: (NSString *)roomKey
{
    NSDictionary* requestSendMessageData = @{@"uid" : APPDELEGATE.uid,
                                             @"message" : message,
                                             @"roomKey" : roomKey
                                             };
    [socketIO emit:@"sendChatroomMessage" withItems:@[requestSendMessageData]];
}

- (void) requestSendImage: (NSString *)image inRoom:(NSString *)roomKey
{
    NSDictionary* requestSendImageData = @{@"uid" : APPDELEGATE.uid,
                                              @"image" : image,
                                              @"roomKey" : roomKey
                                              };
    [socketIO emit:@"chatImage" withItems:@[requestSendImageData]];
}

- (void) requestProfileUpdate: (NSString *)image
{
    NSDictionary* requestProfileUpdateData = @{@"uid" : APPDELEGATE.uid,
                                           @"image" : image,
                                           };
    [socketIO emit:@"profileUpdate" withItems:@[requestProfileUpdateData]];
}

- (void) requestLeaveChatroom: (NSString *)roomKey
{
    NSDictionary* requestLeaveRoomData = @{@"uid" : APPDELEGATE.uid,
                                             @"roomKey" : roomKey
                                             };
    [socketIO emit:@"requestLeaveChatroom" withItems:@[requestLeaveRoomData]];
}

- (void) requestPostComment: (NSString *)comment onFeed: (NSString *)feedId
{
    NSDictionary* requestCommentOnPostData = @{@"uid" : APPDELEGATE.uid,
                                               @"feedId" : feedId,
                                               @"content" : comment
                                               };
    [socketIO emit:@"requestPostComment" withItems:@[requestCommentOnPostData]];
}

- (void) requestLikeFeed: (NSString *)feedId
{
    NSDictionary* requestLikePostData = @{@"uid" : APPDELEGATE.uid,
                                          @"feedId" : feedId
                                          };
    [socketIO emit:@"requestLikeFeed" withItems:@[requestLikePostData]];
}

- (void) requestFeedDetail: (NSString *)feedId
{
    NSDictionary* requestFeedDetailData = @{@"uid" : APPDELEGATE.uid,
                                          @"feedId" : feedId
                                          };
    [socketIO emit:@"requestFeedDetail" withItems:@[requestFeedDetailData]];
}

- (void) requestReportViolationOf:(NSString *)object withId:(NSString *)objectId andReason:(NSString *)reason
{
    NSDictionary *requestReportData = @{@"uid":APPDELEGATE.uid,
                                        @"reportObject":object,
                                        @"objectId":objectId,
                                        @"reportReason":reason
                                        };
    [socketIO emit:@"requestReport" withItems:@[requestReportData]];
}

- (void) requestUserSaveChatroom: (NSString *)roomKey {
    NSDictionary* requestUserSaveChatroomData = @{@"uid" : APPDELEGATE.uid,
                                                  @"roomkey" : roomKey
                                                  };
    [socketIO emit:@"requestUserSaveChatroom" withItems:@[requestUserSaveChatroomData]];
}

#pragma mark - Chatroom Recieved Information

-(void) receiveChatroomList:(NSDictionary *)packet
{
    [APPDELEGATE.chatroomListVC updateChatroomList:packet];
}

- (void) receiveAssignChatroom:(NSDictionary *)packet
{
    [APPDELEGATE.chatVC initRoom:packet];
}

-(void) receiveChatroomUserList:(NSDictionary *)packet
{
    if(APPDELEGATE.chatVC != nil){
        [APPDELEGATE.chatVC updateChatroomUserList:packet];
    }
}

- (void) receivedChatroomMessage: (NSDictionary *)packet
{
    [APPDELEGATE.chatVC receiveMessage:packet];
}


#pragma mark - Bulletin Board Recieved Information

- (void) updateMsgboardMessages: (NSDictionary *)packet
{
    [APPDELEGATE.msglistVC updateMsgboardMessages:packet];
}

-(void) receiveMyProfile:(NSDictionary *)packet
{
    [APPDELEGATE.profileVC receiveMyProfile:packet];
}

-(void) receiveUpdateProfileResponse:(NSDictionary *)packet
{
    [APPDELEGATE.profileVC receiveProfileUpdateRespond:packet];
}

-(void) receiveFeedDetail:(NSDictionary *)packet
{
    [APPDELEGATE.postVC receiveFeedDetail:packet];
}



- (void) socketOnRecievedData
{
    [socketIO onAny:^(SocketAnyEvent* respond) {
        NSLog(@"socket recieved event: %@",respond.event);
        NSString *event = respond.event;
        if([event isEqual:@"disconnect"] || [event isEqual:@"reconnect"] || [event isEqual:@"reconnectAttempt"]){
            return;
        }
        if(respond.items == nil || [respond.items objectAtIndex:0] == nil){
            return;
        }
        NSDictionary *data = [respond.items objectAtIndex:0];
        if([[data objectForKey:@"respond"] isEqualToString:@"RESPOND_FAIL"]){
            [self showDefaultServerErrorAlert];
            
        } else if([event isEqual:@"chatroomList"]){
            [self receiveChatroomList:data];
            
        } else if([event isEqual:@"assignChatroom"]){
            [self receiveAssignChatroom:data];
            
        } else if([event isEqual:@"chatroomMessage"]){
            [self receivedChatroomMessage:data];
            
        } else if([event isEqual:@"chatroomImage"]){
            [self receivedChatroomMessage:data];
            
        } else if([event isEqual:@"messageboardMessages"]){
            [self updateMsgboardMessages:data];
            
        } else if([event isEqual:@"updateChatroomUserList"]){
            [self receiveChatroomUserList:data];
            
        } else if([event isEqual:@"myProfile"]){
            [self receiveMyProfile:data];
            
        } else if([event isEqual:@"profileUpdateResponse"]){
            [self receiveUpdateProfileResponse:data];
            
        } else if([event isEqual:@"feedDetail"]){
            [self receiveFeedDetail:data];
            
        } else if([event isEqual:@"error"]){
            [self showAlertWithTitle:@"Server Error" message:[data objectForKey:@"message"]];
        }
    }];
}

- (void)showDefaultServerErrorAlert{
    [self showAlertWithTitle:@"Server Error" message:@"Woop, something is wrong with our server"];
}

- (void)showAlertWithTitle:(NSString*) title message:(NSString*) message
{
    UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:title
                                                              message:message
                                                             delegate:self
                                                    cancelButtonTitle:@"Okay"
                                                    otherButtonTitles:nil];
    [newMessageAlert show];
}

@end
