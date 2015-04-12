//
//  DetailPostTableViewCell.m
//  ZomeChat
//
//  Created by Brian Lin on 12/4/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "DetailPostTableViewCell.h"

@implementation DetailPostTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.posterImage.layer.cornerRadius = 35;
    self.posterImage.layer.borderWidth = 4;
    self.posterImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.posterImage.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    [self setUserInteractionEnabled:NO];
    
//    self.postContent.layer.cornerRadius = 4;
//    self.postContent.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.postContent.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
