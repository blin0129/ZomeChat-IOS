//
//  ChatroomTableViewCell.h
//  ZomeChat
//
//  Created by Brian Lin on 4/10/15.
//  Copyright (c) 2015 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatroomTableViewCell : UITableViewCell

@property (nonatomic, strong) ChatroomTableViewCell *delegate;

-(void)report:(id)sender;

@end
