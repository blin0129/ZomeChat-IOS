//
//  Room.m
//  ZomeChat
//
//  Created by Brian Lin on 12/27/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "Room.h"

@implementation Room

@synthesize name;
@synthesize key;
@synthesize userCount;
@synthesize index;
@synthesize userTableView;
@synthesize content;
@synthesize roommates;
@synthesize contentView;
@synthesize nextLineY;

-(id)initWithName:(NSString *)roomName Key:(NSString *)roomKey andUserCount:(NSInteger)roomUserCount
{
    self = [super init];
    if (self) {
        self.name = roomName;
        self.key = roomKey;
        self.content = [ChatViewController messagesViewController];
//        self.content = [[NSMutableString alloc] init];
        self.roommates = [[NSMutableArray alloc] init];
        self.userCount = roommates.count;
        
//        self.contentView = [[UITextView alloc] init];
//        self.contentView.backgroundColor = [UIColor clearColor];
//        self.contentView.textColor = [UIColor whiteColor];
//        self.contentView.editable = NO;
//        self.contentView.font = [UIFont systemFontOfSize:20];

        
        self.nextLineY = 0;
        [self createTableView];

    }
    return self;
}

-(void)addContent:(NSString *)msg
{
//    [self.content appendString:msg];
//    [self.content appendString:@"\n"];
//    self.contentView.text = self.content;
//    self.nextLineY = contentView.contentSize.height;
//    [self scrollToBottom];
}

-(void)scrollToBottom
{
//    if(contentView.text.length > 0 ) {
//        NSRange bottom = NSMakeRange(contentView.text.length + 5, 1);
//        [contentView scrollRangeToVisible:bottom];
//    }
}

-(void)addImageSender:(NSString *)senderName
{
//    [self.content appendString:senderName];
//    self.contentView.text = self.content;
//    self.nextLineY = contentView.contentSize.height;
}

-(void)addEmptyLines
{
//    float heightNeeded = self.nextLineY - contentView.contentSize.height;
//    int nSpace = (heightNeeded / contentView.font.lineHeight) + 2;
//    for(int i = 0; i < nSpace; i++){
//        [self.content appendString:@"\n"];
//    }
//    self.contentView.text = self.content;
}

-(void)addImage: (UIImage *)image
{
//    UIImageView *new = [[UIImageView alloc] initWithFrame:CGRectMake(10, nextLineY - 5, image.size.width/2, image.size.height/2)];
//    new.image = image;
//    [self.contentView addSubview:new];
//    self.nextLineY += image.size.height/2;
//    [self addEmptyLines];
//    [self scrollToBottom];
}


-(void)createTableView
{
    userTableView = [[UITableView alloc]init];    
    userTableView.delegate = self;
    userTableView.dataSource = self;
    [userTableView setHidden:TRUE];
    [userTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [userTableView setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"roommates count:%d", roommates.count);
    return roommates.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newRoommateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        
        [cell.imageView setFrame:CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, 120,120)];
    }
    
    if(((User *)[roommates objectAtIndex:indexPath.row]).thumbnail != nil){
        cell.imageView.image = ((User *)[roommates objectAtIndex:indexPath.row]).thumbnail;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"anonicon.png"];
    }
    cell.textLabel.text = ((User *)[roommates objectAtIndex:indexPath.row]).name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Approx %.1f km away",((User *)[roommates objectAtIndex:indexPath.row]).distance];
    
    return cell;
}

-(void) cleanRoom
{
    self.content = nil;
    self.roommates = nil;
    self.contentView = nil;
}


@end
