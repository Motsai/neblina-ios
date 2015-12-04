//
//  SliderViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 23/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "SliderViewController.h"
#import "SWRevealViewController.h"
#import "ViewController.h"
#import "DebugConsoleViewController.h"
#import "ScannerViewController.h"

@implementation SliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mutable_array = [[NSMutableArray alloc] initWithObjects:@"Main Screen", @"Control Panel", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Set the title of navigation bar by using the menu items
//    NSIndexPath *indexPath = [self.tbl_view indexPathForSelectedRow];
//    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
//
//  SliderViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 23/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Menu";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %ld", (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = mutable_array[indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        ViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerdentifire"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        SWRevealViewController *revealController = self.revealViewController;
        [revealController pushFrontViewController:navigationController animated:YES];
    }
    else if (indexPath.row == 1)
    {
        ScannerViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ScannerIdentifire"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        SWRevealViewController *revealController = self.revealViewController;
        [revealController pushFrontViewController:navigationController animated:YES];
     }
}

@end




