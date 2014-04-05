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

    socketIO = APPDELEGATE.socketIO;
    socketIO.delegate = self;
    
    if([CLLocationManager locationServicesEnabled]){
        _currentLocation = APPDELEGATE.locationManager.location;
    }
    self.tabBar.barTintColor = [UIColor darkGrayColor];
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

-(void) requestRoom: (NSDictionary*) requestRoomData
{
    if (APPDELEGATE.chatVC.rooms.count >= 5 ){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"You enter too many rooms"
                                                                  message:@"Plase close some to add a new one"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else if ([self isUserInRoom:[requestRoomData objectForKey:@"roomName"]]){
        [self toChatPage];
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Already in the room"
                                                                  message:@""
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else {
        [socketIO sendEvent:@"requestRoom" withData:requestRoomData];
    }
}

-(BOOL) isUserInRoom:(NSString *)roomName
{
    for(Room *room in APPDELEGATE.chatVC.rooms){
        if([room.name isEqualToString:roomName]){
            return TRUE;
            break;
        }
    }
    return FALSE;
}

-(void) requestCreateNewMessage: (NSString *) messageContent
{
//    NSString *lng = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.longitude];
//    NSString *lat = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.latitude];
    NSDictionary* requestCreatingMessageData = @{@"uid" : APPDELEGATE.userName,
                                              @"lng" : APPDELEGATE.lng,
                                              @"lat" : APPDELEGATE.lat,
                                              @"content" : messageContent
                                              };
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastMessageCreatedTime"];
    [socketIO sendEvent:@"requestCreateMessage" withData:requestCreatingMessageData];
}

-(void) requestMsgboardData
{
//    NSString *lng = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.longitude];
//    NSString *lat = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.latitude];
    NSDictionary* requestMessageboardData = @{@"uid" : APPDELEGATE.userName,
                                              @"lng" : APPDELEGATE.lng,
                                              @"lat" : APPDELEGATE.lat
                                              };
    [socketIO sendEvent:@"requestMessageboard" withData:requestMessageboardData];
}


- (void) requestCreatingNewRoom: (NSString *)roomName
{
//    NSString *lng = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.longitude];
//    NSString *lat = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.latitude];
    NSDictionary* requestCreatingRoomData = @{@"uid" : APPDELEGATE.userName,
                                              @"lng" : APPDELEGATE.lng,
                                              @"lat" : APPDELEGATE.lat,
                                           @"roomName" : roomName
                                           };
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastRoomCreatedTime"];
    [socketIO sendEvent:@"requestCreatingRoom" withData:requestCreatingRoomData];
}

- (void) requestThemeList
{
//    NSString *lng = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.longitude];
//    NSString *lat = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.latitude];
    NSDictionary* requestThemeListData = @{@"uid" : APPDELEGATE.userName,
                                           @"lng" : APPDELEGATE.lng,
                                           @"lat" : APPDELEGATE.lat
                                           };
    [socketIO sendEvent:@"requestThemeList" withData:requestThemeListData];
}

- (void) requestLandingPageInfo
{
//    NSString *lng = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.longitude];
//    NSString *lat = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.latitude];
    NSDictionary* requestLandingPageData = @{@"uid" : APPDELEGATE.userName,
                                             @"lng" : APPDELEGATE.lng,
                                             @"lat" : APPDELEGATE.lat
                                             };
    [socketIO sendEvent:@"requestLandingPage" withData:requestLandingPageData];
}

- (void) requestProfile
{
    NSDictionary* requestProfileData = @{@"uid" : APPDELEGATE.userName};
    [socketIO sendEvent:@"requestProfile" withData:requestProfileData];
}

- (void) requestSendMessage: (NSString *)message inRoom: (NSString *)roomKey
{
    NSDictionary* requestSendMessageData = @{@"uid" : APPDELEGATE.userName,
                                             @"message" : message,
                                             @"roomKey" : roomKey
                                             };
    [socketIO sendEvent:@"message" withData:requestSendMessageData];
}

- (void) requestSendImage: (NSString *)image inRoom:(NSString *)roomKey
{
    NSDictionary* requestSendImageData = @{@"uid" : APPDELEGATE.userName,
                                              @"image" : image,
                                              @"roomKey" : roomKey
                                              };
    [socketIO sendEvent:@"chatImage" withData:requestSendImageData];
}

- (void) requestProfileUpdate: (NSString *)image
{
    NSDictionary* requestProfileUpdateData = @{@"uid" : APPDELEGATE.userName,
                                           @"image" : image,
                                           };
    [socketIO sendEvent:@"profileUpdate" withData:requestProfileUpdateData];
}

- (void) requestLeaveRoom: (NSString *)roomKey
{
    NSDictionary* requestLeaveRoomData = @{@"uid" : APPDELEGATE.userName,
                                             @"roomKey" : roomKey
                                             };
    [socketIO sendEvent:@"leavesRoom" withData:requestLeaveRoomData];
}

- (void) receivedMessage: (SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
    NSString *roomKey = [dic objectForKey:@"roomKey"];
    NSString *message = [dic objectForKey:@"message"];
    [APPDELEGATE.chatVC printMessage:message inRoom:roomKey];
}


- (void) receivedImage: (SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
    NSString *sender = [dic objectForKey:@"uid"];
    NSString *roomKey = [dic objectForKey:@"roomKey"];
    NSString *image = [dic objectForKey:@"image"];
    [APPDELEGATE.chatVC printImage:image inRoom:roomKey fromSender:sender];
}

- (void) receiveLandingPageInfo:(SocketIOPacket *)packet
{
//    NSLog(@"Receive landing Pageinfo");
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
    NSString *userCountString = [NSString stringWithFormat:@"%@ nearby users", [dic objectForKey:@"nearbyUserCount"]];
    NSString *msgCountString = [NSString stringWithFormat:@"%@ msgs", [dic objectForKey:@"messageCount"]];
    NSString *roomCountString = [NSString stringWithFormat:@"%@ rooms", [dic objectForKey:@"themeRoomsCount"]];
    [APPDELEGATE.landVC setUserCount:userCountString msgCount:msgCountString andRoomCount:roomCountString];
}

- (void) receiveAssignRoom:(SocketIOPacket *)packet
{
    [self toChatPage];

    [APPDELEGATE.landVC.navigationController popViewControllerAnimated:YES];
//    [APPDELEGATE.chatVC addARoom:packet];
    [APPDELEGATE.chatVC performSelector:@selector(addARoom:) withObject:packet afterDelay:0.1];
}

- (void) receiveInitRoommate:(SocketIOPacket *)packet
{
    [APPDELEGATE.chatVC performSelector:@selector(initRoommate:) withObject:packet afterDelay:0.1];
}

- (void) updateMsgboardMessages: (SocketIOPacket *)packet
{
    [APPDELEGATE.msglistVC updateMsgboardMessages:packet];
}

-(void) receiveThemeList:(SocketIOPacket *)packet
{
    [APPDELEGATE.themeVC updateThemeList:packet];
}

-(void) receiveRemoveARoommate:(SocketIOPacket *)packet
{
    [APPDELEGATE.chatVC removeARoommate:packet];
}

-(void) receiveAddARoommate:(SocketIOPacket *)packet
{
    [APPDELEGATE.chatVC addARoommate:packet];
}

-(void) receiveMyProfile:(SocketIOPacket *)packet
{
    [APPDELEGATE.profileVC receiveMyProfile:packet];
}

-(void) receiveProfileUpdateResponse:(SocketIOPacket *)packet
{
    [APPDELEGATE.profileVC receiveProfileUpdateRespond:packet];
}

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socket.io connected.");
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if([packet.name isEqual: @"landingPageInfo"]){
        [self receiveLandingPageInfo:packet];
    } else if([packet.name isEqual: @"themeRoomChoice"]){
        [self receiveThemeList:packet];
    } else if([packet.name isEqual: @"assignRoom"]){
        [self receiveAssignRoom:packet];
    } else if([packet.name isEqual: @"broadcastMessage"]){
        [self receivedMessage:packet];
    } else if([packet.name isEqual:@"broadcastImage"]){
        [self receivedImage:packet];
    } else if([packet.name isEqual: @"messageboardMessages"]){
        [self updateMsgboardMessages:packet];
    } else if([packet.name isEqual:@"initRoommate"]){
        [self receiveInitRoommate:packet];
    } else if([packet.name isEqual:@"removeARoommate"]){
        [self receiveRemoveARoommate:packet];
    } else if([packet.name isEqual:@"addARoommate"]){
        [self receiveAddARoommate:packet];
    }  else if([packet.name isEqual:@"myProfile"]){
        [self receiveMyProfile:packet];
    }   else if([packet.name isEqual:@"profileUpdateResponse"]){
        [self receiveProfileUpdateResponse:packet];
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
