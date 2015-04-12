//
//  CommentTableViewCell.m
//  ZomeChat
//
//  Created by Brian Lin on 12/5/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    [self setUserInteractionEnabled:NO];
//        self.contentTextview.layer.cornerRadius = 4;
//        self.contentTextview.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        self.contentTextview.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (float)calculateHeight {
    float height = self.usernameLabel.frame.size.height + self.contentTextview.frame.size.height + 20;
    return height;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(report:))
    {
        return YES;
    }
    return NO;
}

-(void)report:(id)sender
{
    UIView* v = self;
    do {
        v = v.superview;
    } while (![v isKindOfClass:[UITableView class]]);
    UITableView* cv = (UITableView*) v;
    // ask it what index path we are
    NSIndexPath* ip = [cv indexPathForCell:self];
    if (cv.delegate && [cv.delegate respondsToSelector: @selector(tableView:performAction:forRowAtIndexPath:withSender:)]){
        [cv.delegate tableView:cv performAction:_cmd forRowAtIndexPath:ip withSender:sender];
    }
}

@end
