//
//  MessagePageViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 1/8/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewPostViewController.h"

@interface BulletinPageViewController : UITableViewController <UITextFieldDelegate>
@property int timeSinceLastMessage;
@property (strong, nonatomic) NSMutableArray *messageList;
@property (strong, nonatomic) NSMutableDictionary *hashTagDictionary;
@property (strong , nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSMutableDictionary *selectedData;
@property BOOL pictureLoaded;

- (void) updateMsgboardMessages:(NSDictionary *)packet;
- (void) updateFeedStatus:(NSString *)feedId likeCount:(NSNumber *)likesCount commentCount:(NSNumber *) commentsCount;

@end
