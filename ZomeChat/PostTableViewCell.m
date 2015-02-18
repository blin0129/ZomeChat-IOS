//
//  PostTableViewCell.m
//  ZomeChat
//
//  Created by Brian Lin on 12/6/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "PostTableViewCell.h"

@implementation PostTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.boxView.layer.masksToBounds = NO;
    self.boxView.layer.cornerRadius = 4;
    self.boxView.layer.shadowOffset = CGSizeMake(2, 2);
    self.boxView.layer.shadowRadius = 2;
    self.boxView.layer.shadowOpacity = 0.3;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentTextview.userInteractionEnabled = NO;
    
//    self.contentTextview.layer.cornerRadius = 4;
//    self.contentTextview.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.contentTextview.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
