//
//  LandingPageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 12/18/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "LandingPageViewController.h"
#import "LoginViewController.h"


@interface LandingPageViewController ()

@end

@implementation LandingPageViewController{
    GMSMapView *mapView;
}

@synthesize mapContainer;
@synthesize editProfileButton;
@synthesize themeListButton;
@synthesize messageBoardButton;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        APPDELEGATE.landVC = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

//    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
//                                initWithTitle:@""
//                                style:UIBarButtonItemStyleBordered
//                                target:self
//                                action:nil];
//    self.navigationItem.backBarButtonItem = btnBack;
    
    //Background
    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-lightblue.png"]];
    backgroundIV.frame = self.view.bounds;
    [self.view addSubview:backgroundIV];
    [self.view sendSubviewToBack:backgroundIV];
    
    //Buttons
    themeListButton.layer.borderWidth = 2;
    themeListButton.layer.borderColor = [UIColor whiteColor].CGColor;
    themeListButton.layer.cornerRadius = 8;
    themeListButton.layer.masksToBounds = YES;
   
    messageBoardButton.layer.borderWidth = 2;
    messageBoardButton.layer.borderColor = [UIColor whiteColor].CGColor;
    messageBoardButton.layer.cornerRadius = 8;
    messageBoardButton.layer.masksToBounds = YES;
    
    editProfileButton.layer.borderWidth = 2;
    editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
    editProfileButton.layer.cornerRadius = 8;
    editProfileButton.layer.masksToBounds = YES;
    
    [self loadMap];
    [APPDELEGATE.mainVC requestLandingPageInfo];
    if([APPDELEGATE.loginType isEqualToString:@"Anonymous"]){
        [editProfileButton setHidden:TRUE];
    }
}

//- (void) viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}

- (void) updateRoomCount:(NSString *) roomCount
{
    NSString* roomCountString = [NSString stringWithFormat:@"%@ rooms", roomCount];
    [_roomCountLabel setText:roomCountString];
}

- (void) updateMessageCount:(NSString *) msgCount
{
    NSString* msgCountString = [NSString stringWithFormat:@"%@ msgs", msgCount];

    [_msgCountLabel setText:msgCountString];
}

- (void) loadMap
{
    double lat = [APPDELEGATE.mainVC getLatitude];
    double lng = [APPDELEGATE.mainVC getLongitude];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lng
                                                                 zoom:15];
    mapView = [GMSMapView mapWithFrame:mapContainer.bounds camera:camera];
//    mapView.myLocationEnabled = YES;
    [mapContainer addSubview:mapView];

//    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(lat, lng);
    marker.title = @"Your Location";
//    marker.snippet = @"Australia";
    marker.map = mapView;

//    UIGraphicsBeginImageContext(mapView.frame.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [mapView.layer drawInContext:context];
//    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
//    test = [[UIImageView alloc] initWithImage:screenShot];
//    [test setBackgroundColor:[UIColor blueColor]];
//    [self.view addSubview:test];
//    CGRect rect = test.frame;
//    rect.origin.y += 100;
//    test.frame = rect;
//    UIGraphicsEndImageContext();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)toMessagePage:(id)sender {
    [APPDELEGATE.mainVC toMessagePage];
}

- (void) requestThemeList
{
    [APPDELEGATE.mainVC requestThemeList];

}

-(void) setUserCount:(NSString *)userCount msgCount:(NSString *)msgCount andRoomCount:(NSString *)roomCount
{
    [_nearbyUserCountLabel setText:userCount];
    [_msgCountLabel setText:msgCount];
    [_roomCountLabel setText:roomCount];
}
@end
