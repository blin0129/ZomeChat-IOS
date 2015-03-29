//
//  AppDelegate.h
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"
//#import "SwiftIO/"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import "BulletinPageViewController.h"
#import "ChatViewController.h"
#import "ChatroomListViewController.h"
#import "PostTable.h"
#import "ProfilePageViewController.h"
#import "PostViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>{
    NSMutableString *userName;
    NSMutableString *uid; //equal to email
}

@property (strong, nonatomic) NSString *version;
@property (nonatomic, strong) SocketIO *socketIO;
@property (strong, nonatomic) MainViewController *mainVC;
@property (strong, nonatomic) ChatroomListViewController *chatroomListVC;
@property (strong, nonatomic) ChatViewController *chatVC;
@property (strong, nonatomic) BulletinPageViewController *msglistVC;
@property (strong, nonatomic) ProfilePageViewController *profileVC;
@property (strong, nonatomic) PostViewController *postVC;
@property UIBackgroundTaskIdentifier backgroundTask;

@property (strong, nonatomic) NSString *lng;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *serverURL;
@property NSInteger listeningPort;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableString *userName;
@property (nonatomic, retain) NSMutableString *uid;
@property (nonatomic, retain) NSString *loginType;
@property (strong, nonatomic) NSCache *imageCache;

//Constraints Setting
@property BOOL changeUserImage; //(ProfilePageViewController) Disable UIView interation
@property BOOL changeUsername; //(ProfilePageViewController) Remove 'editUsername' button
@property BOOL commentPost; //(PostViewController) Aleart when click 'send' button
@property BOOL likePost; //(PostViewController) Alert when click 'like' button
@property BOOL postFeed; //(BulletinPageViewController) Aleart when click 'plus' button
@property BOOL postFeedImage; //(NewPostViewController) Alert when click 'camera' button
@property BOOL createChatroom; //(ChatroomListViewController) Alerat when click 'plus' button
@property BOOL chatroomConversation; //(ChatViewController) Alert when click 'send' button
@property BOOL chatroomSendImage; //(ChatViewController) Alert when click 'camera' button
@property float postingFeedTimerOffset; //(BulletinPageViewCOntroller)Alert
@property float creatingChatroomTimerOffset; //(ChatroomListViewController) Alert

@property int usernameMaxLength;
@property int postContentMaxChars;
@property int postContentMaxLines;
@property int chatMessageMaxChars;
@property int chatMessageMaxLines;

//Alert Message Setting
@property (strong, nonatomic) NSString *commentPostAlertTitle;
@property (strong, nonatomic) NSString *commentPostAlertMessage;
@property (strong, nonatomic) NSString *likePostAlertTitle;
@property (strong, nonatomic) NSString *likePostAlertMessage;
@property (strong, nonatomic) NSString *postFeedAlertTitle;
@property (strong, nonatomic) NSString *postFeedAlertMessage;
@property (strong, nonatomic) NSString *postImageAlertTitle;
@property (strong, nonatomic) NSString *postImageAlertMessage;
@property (strong, nonatomic) NSString *createChatroomAlertTitle;
@property (strong, nonatomic) NSString *createChatroomAlertMessage;
@property (strong, nonatomic) NSString *chatroomSendImageAlertTitle;
@property (strong, nonatomic) NSString *chatroomSendImageAlertMessage;
@property (strong, nonatomic) NSString *chatroomConversationAlertTitle;
@property (strong, nonatomic) NSString *chatroomConversationAlertMessage;
@property (strong, nonatomic) NSString *postDoubleLikedAlertTitle;
@property (strong, nonatomic) NSString *postDoubleLikedAlertMessage;
@property (strong, nonatomic) NSString *firstPostAlertTitle;
@property (strong, nonatomic) NSString *firstPostAlertMessage;
@property (strong, nonatomic) NSString *noTaggedFeedAlertTitle;
@property (strong, nonatomic) NSString *noTaggedFeedAlertMessage;

- (void) updateLocationCalled;
- (void) connectServer;
- (void) disconnectServer;

- (void) setFacebookUserConstrains;
- (void) setRegularUserConstrains;
- (void) setAnonymouseUserConstrains;

@end
