//
//  ChatroomUserTable.m
//  ZomeChat
//
//  Created by Brian Lin on 6/16/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "ChatroomUserTable.h"
#import "UIImage+ProportionalFill.h"

@interface ChatroomUserTable ()

@end

@implementation ChatroomUserTable

@synthesize chatroomUsers;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.chatroomUsers = [[NSMutableArray alloc] init];
//    for (NSDictionary *obj in APPDELEGATE.chatVC.chatroomUsers){
//        [self.chatroomUsers addObject:obj];
//    }
    self.chatroomUsers = [APPDELEGATE.chatVC.chatroomUsers mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatroomUsers.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [sectionView setBackgroundColor:UIColorFromRGB(0xcbe1ed)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -3, tableView.bounds.size.width, 30)];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [sectionView addSubview:titleLabel];
    
    switch (section) {
        case 0:
            titleLabel.text = @"Chatrooms Users";
            break;
        default:
            titleLabel.text = @"";
            break;
    }
    
    return sectionView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        
    }
    cell.textLabel.text = [[self.chatroomUsers objectAtIndex:indexPath.row] objectForKey:@"userName"];
    UIImage *profilePicture = [self getImageFromURL:[[self.chatroomUsers objectAtIndex:indexPath.row] objectForKey:@"imageURL"]];
    if(profilePicture == nil){
        profilePicture = [UIImage imageNamed:@"anonymous"];
    }
    cell.imageView.image = [self resizeImage:profilePicture];
//    cell.textLabel.text = [self.chatroomUsers objectForKey:@"userName"];
    
    return cell;
}

- (UIImage *) resizeImage:(UIImage *)originalImage {
    CGSize newSize = CGSizeMake(100, 100);
    UIImage *newImage =[originalImage imageCroppedToFitSize:newSize];
    return newImage;
}

- (UIImage *) getImageFromURL: (NSString *) imageURL{
    if ([imageURL isEqualToString:@""]) {
        return nil;
    }
    UIImage *img = [APPDELEGATE.imageCache objectForKey:imageURL];
    if(!img){
        img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: imageURL]]];
        [APPDELEGATE.imageCache setObject:img forKey:imageURL];
    }
    return [self resizeImage:img];
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
