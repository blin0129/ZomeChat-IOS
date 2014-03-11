//
//  User.m
//  ZomeChat
//
//  Created by Brian Lin on 12/27/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize name;
@synthesize id;
@synthesize distance;
@synthesize thumbnail;
@synthesize lat;
@synthesize lng;

-(id)initWithName:(NSString *)userName
{
    self = [super init];
    if (self) {
        self.name = userName;
        self.distance = 0;
        self.thumbnail = nil;
    }
    return self;
}

-(void) addCoordinate:(float) longtitude :(float) latitude
{
    self.lat = latitude;
    self.lng = longtitude;
}

-(void) addDistance:(double) dist
{
    self.distance = dist / 1000;
    //self.distance in km
}

-(void) addThumbnail:(UIImage *) image
{
    self.thumbnail = image;
}

-(void) cleanThumbnail
{
    self.thumbnail = nil;
}

@end
