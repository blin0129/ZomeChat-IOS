//
//  ThemeListViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 12/20/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface ThemeListViewController : UITableViewController

-(void) updateThemeList:(SocketIOPacket *)packet;

@end
