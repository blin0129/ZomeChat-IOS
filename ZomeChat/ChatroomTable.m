//
//  ThemeListViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 12/20/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "ChatroomTable.h"
#import "ChatPageViewController.h"
#import "SocketIOPacket.h"

@interface ChatroomTable ()

@end

@implementation ChatroomTable

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
//        APPDELEGATE.themeVC = self;
        NSLog(@"New Theme List table is created");
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
    [self.tableView reloadData];
//    [APPDELEGATE.mainVC requestThemeList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateThemeList:(SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    APPDELEGATE.mainVC.defaultRoomList = [[NSMutableArray alloc] initWithObjects: nil];

    NSDictionary *popRoom = @{@"roomName":@"Popular Room",
                              @"userCount":[dic objectForKey:@"popRoomUsers"],
                              @"distance":@"0"
                              };
    NSDictionary *locRoom = @{@"roomName":@"Local Room",
                              @"userCount":[dic objectForKey:@"locRoomUsers"],
                              @"distance":@"0"
                              };
    
    [APPDELEGATE.mainVC.defaultRoomList addObject:popRoom];
    [APPDELEGATE.mainVC.defaultRoomList addObject:locRoom];

    NSArray *receiveList = [self sortThemeList:[dic objectForKey:@"choices"]];
    for(int i=0;i<receiveList.count;i++)
    {
        NSLog(@"%@",[[receiveList objectAtIndex:i] objectForKey:@"distance"]);
        [APPDELEGATE.mainVC.defaultRoomList addObject:[receiveList objectAtIndex:i]];
    }
//    [APPDELEGATE.landVC updateRoomCount:[NSString stringWithFormat:@"%lu",(unsigned long)APPDELEGATE.mainVC.defaultRoomList.count]];
    [self.tableView reloadData];
}

-(NSArray *) sortThemeList:(NSArray *)receiveList
{
    NSArray *sortedArray = [receiveList sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
        float dist1 = [[item1 objectForKey:@"distance"] floatValue];
        float dist2 = [[item2 objectForKey:@"distance"] floatValue];
        if (dist1 > dist2)
            return NSOrderedDescending;
        else if (dist1 < dist2)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    return sortedArray;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return APPDELEGATE.mainVC.defaultRoomList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ThemeListCell";
    UIView *cellBackground;
    UILabel *userCountLabel;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

     
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
//        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x+10, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width-10, cell.textLabel.frame.size.height);
        
        cellBackground = [[UIView alloc] initWithFrame:CGRectMake(5,5, cell.frame.size.width-15, cell.frame.size.height-5)];
        cellBackground.layer.borderWidth = 2;
        cellBackground.layer.borderColor = [UIColor whiteColor].CGColor;
        cellBackground.layer.cornerRadius = 8;
//        cellBackground.layer.masksToBounds = YES;
        [cell.contentView addSubview:cellBackground];
        [cell.contentView sendSubviewToBack:cellBackground];
        
        userCountLabel = [[UILabel alloc] init];
        userCountLabel.font = [UIFont systemFontOfSize:14];
        userCountLabel.textColor = [UIColor whiteColor];
        userCountLabel.tag = 2;
        [cell.contentView addSubview:userCountLabel];
        
        [userCountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:userCountLabel
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cellBackground
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:-10]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:userCountLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cellBackground
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0]];

    } else {
        userCountLabel = (UILabel *)[cell.contentView viewWithTag:2];
    }
    
    NSString *userCountString = [NSString stringWithFormat:@"%@ users",[[APPDELEGATE.mainVC.defaultRoomList objectAtIndex:indexPath.row] objectForKey:@"userCount"]];
    userCountLabel.text = userCountString;
    [userCountLabel sizeToFit];
    
    cell.textLabel.text = [[APPDELEGATE.mainVC.defaultRoomList objectAtIndex:indexPath.row] objectForKey:@"roomName"];
    
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *currentString = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    NSLog(@"didSelectRow called %@", currentString);
    
    NSString *roomType;
    NSString *roomName;
    NSString *roomKey = @"";
    
    if(indexPath.row == 0){
        roomType = @"0";
        roomName = @"Popular Room";
    } else if (indexPath.row == 1){
        roomType = @"1";
        roomName= @"Local Room";
    } else {
        roomType = @"2";
        roomName = [[APPDELEGATE.mainVC.defaultRoomList objectAtIndex:indexPath.row] objectForKey:@"roomName"];
        roomKey = [[APPDELEGATE.mainVC.defaultRoomList objectAtIndex:indexPath.row] objectForKey:@"roomKey"];
    }
    
    NSDictionary* requestRoomData = @{@"uid" : APPDELEGATE.userName,
                                      @"roomName" : roomName,
                                           @"roomType" : roomType,
                                           @"roomKey" : roomKey,
                                           };
//    [APPDELEGATE.mainVC requestRoom:requestRoomData];

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
