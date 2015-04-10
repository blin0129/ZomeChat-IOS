//
//  AppDelegate.m
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "AppDelegate.h"
#import "ZomeChat-Swift.h"

@implementation AppDelegate {
    BOOL manuelLocationUpdate;
}

@synthesize window = _window;
@synthesize locationManager=_locationManager;
@synthesize socketIO;
@synthesize userName;
@synthesize uid;
@synthesize lng;
@synthesize lat;
@synthesize serverURL;
@synthesize backgroundTask;
@synthesize imageCache;
@synthesize version;
@synthesize listeningPort;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    version = @"1.12";
    userName = [[NSMutableString alloc] init];
    imageCache = [[NSCache alloc] init];
    //Berkeley
//    lng = @"-122.260505";
//    lat = @"37.872045";
    
    //SF
    lng = @"-122.408225";
    lat = @"37.7873560";
//    serverURL = @"ec2-54-205-59-87.compute-1.amazonaws.com:1442";
    serverURL = @"localhost:1442";

    [self initAppSetting];
    [self initLocationManager];
    [self connectServer];
    [GMSServices provideAPIKey:@"AIzaSyD_K5ZnON6GNk1KsNROdG3oI0NpDCj0MRc"];
    return YES;
}

- (void) initAppSetting
{
    //Navation Bar Style
    self.window.tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor grayColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],UITextAttributeTextColor,
      [UIColor whiteColor],UITextAttributeTextShadowColor,
      nil]];
    [self setInitialConstraints];
    [self initAlartMessages];
    
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
}

- (void) connectServer
{
    socketIO = [[SocketIOClient alloc] initWithSocketURL:serverURL options:@{@"reconnects": @true}];
    [socketIO connect];
//    [socketIO on: @"connect" callback: ^(NSArray* data, void (^ack)(NSArray*)) {
//        NSLog(@"Server connected");
//    }];
}

- (void) disconnectServer
{
    NSLog(@"Reconnect server");
    [socketIO closeWithFast:@true];
    [socketIO connect];
}

- (void) initLocationManager
{
    manuelLocationUpdate = false;
    if(self.locationManager==nil){
        _locationManager=[[CLLocationManager alloc] init];
        //I'm using ARC with this project so no need to release
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter=500;
        self.locationManager=_locationManager;
    }
    
    if([CLLocationManager locationServicesEnabled]){
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startUpdatingLocation];
    }
}

- (void) updateLocationCalled {
    manuelLocationUpdate = true;
    if(self.locationManager==nil){
        _locationManager=[[CLLocationManager alloc] init];
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter=500;
        self.locationManager=_locationManager;
    }
    
    if([CLLocationManager locationServicesEnabled]){
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * currentLocation = (CLLocation *)[locations lastObject];
    if (currentLocation != nil)
    {
        lat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        lng = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        if(manuelLocationUpdate){
            [self.mainVC requestLocationUpdate];
            [self.mainVC updateLocationOnMap];
            manuelLocationUpdate = false;
        }
    }
    [manager stopUpdatingLocation];
}

- (void)initAlartMessages{
    self.commentPostAlertTitle = @"You are in \"Browse Mode\"";
    self.commentPostAlertMessage = @"Please log in to comment on the post";
    
    self.likePostAlertTitle = @"You are in \"Browse Mode\"";
    self.likePostAlertMessage = @"Please log in to like this post";
    
    self.postFeedAlertTitle = @"You are in \"Browse Mode\"";
    self.postFeedAlertMessage = @"Please log in to make a new post";
    
    self.postImageAlertTitle = @"You are in \"Browse Mode\"";
    self.postImageAlertMessage = @"Please log in to attach an image to the post";
    
    self.createChatroomAlertTitle = @"You are in \"Browse Mode\"";
    self.createChatroomAlertMessage = @"Please log in to create a custom chatroom";
    
    self.chatroomSendImageAlertTitle = @"You are in \"Browse Mode\"";
    self.chatroomSendImageAlertMessage = @"Please log in to send an image";
    
    self.chatroomConversationAlertTitle = @"You are in \"Browse Mode\"";
    self.chatroomConversationAlertMessage = @"Please log in to chat with others";
    
    self.postDoubleLikedAlertTitle = @"";
    self.postDoubleLikedAlertMessage = @"You've liked this post already";
    
    self.firstPostAlertTitle = @"No Posts In Your Area Yet";
    self.firstPostAlertMessage = nil;
    
    self.noTaggedFeedAlertTitle = @"No Match Found";
    self.noTaggedFeedAlertMessage = @"No tagged post around your area";
}

- (void)setInitialConstraints{
    self.changeUserImage = NO;
    self.commentPost = NO;
    self.likePost = NO;
    self.postFeed = NO;
    self.postFeedImage = NO;
    self.createChatroom = NO;
    self.chatroomConversation = NO;
    self.chatroomSendImage = NO;
    self.changeUsername = NO;
    
    self.postingFeedTimerOffset = 0;
    self.creatingChatroomTimerOffset = 120;
}

- (void)setFacebookUserConstrains{
    self.changeUserImage = YES;
    self.commentPost = YES;
    self.likePost = YES;
    self.postFeed = YES;
    self.postFeedImage = YES;
    self.createChatroom = YES;
    self.chatroomConversation = YES;
    self.chatroomSendImage = YES;
    self.changeUsername = YES;
}

- (void)setRegularUserConstrains{
    self.changeUserImage = YES;
    self.commentPost = YES;
    self.likePost = YES;
    self.postFeed = YES;
    self.postFeedImage = YES;
    self.createChatroom = YES;
    self.chatroomConversation = YES;
    self.chatroomSendImage = YES;
    self.changeUsername = YES;
}

- (void)setAnonymouseUserConstrains{
    self.changeUserImage = NO;
    self.commentPost = NO;
    self.likePost = NO;
    self.postFeed = NO;
    self.postFeedImage = NO;
    self.createChatroom = NO;
    self.chatroomConversation = NO;
    self.chatroomSendImage = NO;
    self.changeUsername = NO;
}

//For facebook API
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
