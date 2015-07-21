//
//  ChatroomUserTable.h
//  ZomeChat
//
//  Created by Brian Lin on 6/16/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatroomUserTable : UITableViewController

@property (strong, nonatomic) NSMutableArray *chatroomUsers;
@property (strong, nonatomic) NSString *reportUserId;

@end
