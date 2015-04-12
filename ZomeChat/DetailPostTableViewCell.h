//
//  DetailPostTableViewCell.h
//  ZomeChat
//
//  Created by Brian Lin on 12/4/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailPostTableViewCell : UITableViewCell

@property (nonatomic, strong) DetailPostTableViewCell *delegate;

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UITextView *postContent;
@property (strong, nonatomic) IBOutlet UIImageView *posterImage;
@property (strong, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIView *containerView;

-(void)report:(id)sender;

@end
