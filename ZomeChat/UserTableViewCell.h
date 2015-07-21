//
//  UserTableViewCell.h
//  ZomeChat
//
//  Created by Brian Lin on 4/10/15.
//  Copyright (c) 2015 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell

@property (nonatomic, strong) UserTableViewCell *delegate;

-(void)report:(id)sender;

@end
