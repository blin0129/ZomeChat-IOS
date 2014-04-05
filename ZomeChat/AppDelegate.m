//
//  AppDelegate.m
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize locationManager=_locationManager;
@synthesize socketIO = _socketIO;
@synthesize userName;
@synthesize lng;
@synthesize lat;
@synthesize serverURL;
@synthesize backgroundTask;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    userName = [[NSMutableString alloc] init];
    lng = @"0";
    lat = @"0";
    serverURL = @"10.0.0.5";
//    serverURL = @"ec2-54-205-59-87.compute-1.amazonaws.com";
//    serverURL = @"192.168.5.82";
    
    self.window.tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    if(self.locationManager==nil){
        _locationManager=[[CLLocationManager alloc] init];
        //I'm using ARC with this project so no need to release
        
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter=500;
        self.locationManager=_locationManager;
    }

    if([CLLocationManager locationServicesEnabled]){
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startUpdatingLocation];
    }
    
    if (!_socketIO || ![_socketIO isConnected]) {
        _socketIO = [[SocketIO alloc] init];
        //        _socketIO = [[SocketIO alloc] initWithDelegate:self];
        [_socketIO connectToHost:serverURL onPort:1442];
        //Local
        //private String URL = "http://10.0.0.5:1442";
        //Heroku
        //    private String URL = "http://pacific-eyrie-2493.herokuapp.com:1442";
        //Amazon ec2
        //    private String URL = "http://ec2-54-205-59-87.compute-1.amazonaws.com:1442";
    }
    
    [GMSServices provideAPIKey:@"AIzaSyD_K5ZnON6GNk1KsNROdG3oI0NpDCj0MRc"];
    
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    return YES;
}

- (void) serverReconnect {
    if (![_socketIO isConnected]) {
        [_socketIO connectToHost:serverURL onPort:1442];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
//    NSDate* eventDate = newLocation.timestamp;
//    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    lng = [NSString stringWithFormat:@"%+.6f", oldLocation.coordinate.longitude];
    lat = [NSString stringWithFormat:@"%+.6f", oldLocation.coordinate.latitude];
    
    if(newLocation.horizontalAccuracy < 35.0){
        //Location seems pretty accurate, let's use it!
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        NSLog(@"Horizontal Accuracy:%f", newLocation.horizontalAccuracy);
        lng = [NSString stringWithFormat:@"%+.6f", newLocation.coordinate.longitude];
        lat = [NSString stringWithFormat:@"%+.6f", newLocation.coordinate.latitude];
        //Optional: turn off location services once we've gotten a good location
        [manager stopUpdatingLocation];
    }
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
