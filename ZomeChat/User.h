//
//  User.h
//  ZomeChat
//
//  Created by Brian Lin on 12/27/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property NSString *name;
@property NSNumber *id;
@property double distance;
@property UIImage *thumbnail;
@property float lat;
@property float lng;

-(id)initWithName:(NSString *)userName;
-(void) addCoordinate:(float)longtitude :(float)latitude;
-(void) addDistance:(double) dist;
-(void) addThumbnail:(UIImage *) image;
-(void) cleanThumbnail;

@end
