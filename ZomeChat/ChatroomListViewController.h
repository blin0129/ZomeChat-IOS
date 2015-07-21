//
//  ThemePageViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 1/7/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatroomListViewController : UITableViewController <UITextFieldDelegate>

@property int timeSinceLastRoom;
@property NSString *choosedRoomName;
@property NSString *choosedRoomKey;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (strong, nonatomic) NSString *popupType;
@property (strong, nonatomic) NSString *reportChatroomId;

-(void) updateChatroomList:(NSDictionary *)packet;

@end
