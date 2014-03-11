//
//  MessageListViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 1/8/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "MessageListViewController.h"

@interface MessageListViewController ()

@end

@implementation MessageListViewController
@synthesize messageList;
@synthesize cellHeight;
@synthesize tableWidth;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        APPDELEGATE.msglistVC = self;
    }
    return self;
}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    messageList = [[NSMutableArray alloc] initWithObjects:nil];
    [APPDELEGATE.mainVC requestMsgboardData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateMsgboardMessages:(SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    [messageList removeAllObjects];
    NSArray *receiveList = [self sortMessageList:[dic objectForKey:@"messages"]];
    for (NSDictionary *obj in receiveList){
        [messageList addObject:obj];
    }
    [self.tableView reloadData];
    [APPDELEGATE.landVC updateMessageCount:[NSString stringWithFormat:@"%lu",(unsigned long)receiveList.count]];

    if(self.tableView.contentSize.height >= self.view.frame.size.height){
    [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.contentSize.height - self.tableView.bounds.size.height) animated:NO];
    }
}

-(NSArray *) sortMessageList:(NSArray *)receiveList
{
    NSArray *sortedArray = [receiveList sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
        float time1 = [[item1 objectForKey:@"time"] floatValue];
        float time2 = [[item2 objectForKey:@"time"] floatValue];
        if (time1 > time2)
            return NSOrderedDescending;
        else if (time1 < time2)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    return sortedArray;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    tableWidth = tableView.frame.size.width;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageBoardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *name;
    UILabel *time;
    UITextView *content;
    UIView *cellBackground;
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cellBackground = [[UIView alloc] init];
        cellBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];

        name = [[UILabel alloc] init];
        name.tag = 1;
        name.textColor = [UIColor whiteColor];
        name.font = [UIFont systemFontOfSize:12];
        
        time = [[UILabel alloc] init];
        time.tag = 2;
        time.textColor = [UIColor lightGrayColor];
        time.font = [UIFont systemFontOfSize:12];

        content = [[UITextView alloc] init];
        content.tag =3;
        content.font = [UIFont systemFontOfSize:14];
        content.backgroundColor = [UIColor clearColor];
        content.textColor = [UIColor whiteColor];
        content.userInteractionEnabled = FALSE;
        
        [cell.contentView addSubview:name];
        [cell.contentView addSubview:time];
        [cell.contentView addSubview:content];
        [cell.contentView addSubview:cellBackground];
        [cell.contentView sendSubviewToBack:cellBackground];
        
        [cellBackground setTranslatesAutoresizingMaskIntoConstraints:NO];
        [name setTranslatesAutoresizingMaskIntoConstraints:NO];
        [time setTranslatesAutoresizingMaskIntoConstraints:NO];
        [content setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cellBackground
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:5]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cellBackground
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:-5]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cellBackground
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:5]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cellBackground
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:5]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:time
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:10]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:time
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:-10]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:name
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:10]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:name
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:10]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:content
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:10]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:content
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:-10]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:content
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:5]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:content
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:name
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:-5]];
    } else {
        name = (UILabel *)[cell.contentView viewWithTag:1];
        time = (UILabel *)[cell.contentView viewWithTag:2];
        content = (UITextView *)[cell.contentView viewWithTag:3];
    }
    
    name.text = [[messageList objectAtIndex:indexPath.row] objectForKey:@"owner"];
    NSString *timeFormat = [NSString stringWithFormat:@"%@/%@/%@ %@:%@",
                            [[messageList objectAtIndex:indexPath.row] objectForKey:@"month"],
                            [[messageList objectAtIndex:indexPath.row] objectForKey:@"date"],
                            [[messageList objectAtIndex:indexPath.row] objectForKey:@"year"],
                            [[messageList objectAtIndex:indexPath.row] objectForKey:@"hour"],
                            [[messageList objectAtIndex:indexPath.row] objectForKey:@"min"]];
    time.text = timeFormat;
    
    content.text = [[messageList objectAtIndex:indexPath.row] objectForKey:@"content"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[[messageList objectAtIndex:indexPath.row] objectForKey:@"content"] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:14.0]}];
    
    // check the cache first if enabled
#if PERFORMANCE_ENABLE_HEIGHT_CACHE
    NSNumber *cachedHeight = self.rowHeightCache[content.uniqueIdentifier];
    
    if (cachedHeight != nil) {
        return [cachedHeight floatValue];
    }
#endif
    
    float viewWidth = tableView.frame.size.width - 40;
    CGRect theSize = [content boundingRectWithSize:CGSizeMake(viewWidth, CGFLOAT_MAX)
                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           context:nil];
    float calculatedHeight = theSize.size.height+35;
    
#if PERFORMANCE_ENABLE_HEIGHT_CACHE
    self.rowHeightCache[message.uniqueIdentifier] = @(calculatedHeight);
#endif
    
    return calculatedHeight;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
