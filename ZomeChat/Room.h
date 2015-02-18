//
//  Room.h
//  ZomeChat
//
//  Created by Brian Lin on 12/27/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "ChatViewController.h"

@interface Room : NSObject <UITableViewDataSource, UITableViewDelegate>

@property NSString *name;
@property NSInteger index;
@property NSString *key;
@property NSInteger userCount;
@property NSMutableArray *roommates;
@property NSMutableString *content;
@property (strong, nonatomic) UITableView *userTableView;
@property (strong, nonatomic) ChatViewController *contentView;
//@property (strong, nonatomic) UITextView *contentView;
@property float nextLineY;

-(id)initWithName:(NSString *)roomName Key:(NSString *)roomKey andUserCount:(NSInteger)roomUserCount;
-(void)addContent:(NSString *)msg;
-(void)addImage: (UIImage *)image;
-(void)addImageSender:(NSString *)name;
-(void)cleanRoom;

@end
