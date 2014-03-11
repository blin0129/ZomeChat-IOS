//
//  MessageListViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 1/8/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIOPacket.h"

@interface MessageListViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *messageList;
@property NSMutableArray *cellHeight;
@property float tableWidth;

-(void) updateMsgboardMessages:(SocketIOPacket *)packet;

@end


