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
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import "LandingPageViewController.h"
#import "ChatPageViewController.h"
#import "ThemeListViewController.h"
#import "MessageListViewController.h"
#import "ProfilePageViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>{
    NSMutableString *userName;
}

@property (nonatomic, strong) SocketIO *socketIO;
@property (strong, nonatomic) MainViewController *mainVC;
@property (strong, nonatomic) LandingPageViewController *landVC;
@property (strong, nonatomic) ThemeListViewController *themeVC;
@property (strong, nonatomic) ChatPageViewController *chatVC;
@property (strong, nonatomic) MessageListViewController *msglistVC;
@property (strong, nonatomic) ProfilePageViewController *profileVC;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property NSString *lng;
@property NSString *lat;
@property NSString *serverURL;


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableString *userName;
@property (nonatomic, retain) NSString *loginType;


- (void) serverReconnect;

@end
