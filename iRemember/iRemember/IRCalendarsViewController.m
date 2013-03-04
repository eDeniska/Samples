//
//  IRCalendarsViewController.m
//  iRemember
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "IRCalendarsViewController.h"
#import "IRRemainderManager.h"
#import "IRItemsViewController.h"

@interface IRCalendarsViewController ()

@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, strong) IRRemainderManager *remainderManager;

@end

@implementation IRCalendarsViewController

-(void)resignActive:(NSNotification*)notification
{
#warning TODO: disable UI
}

-(void)accessGranted:(NSNotification*)notification
{
#warning TODO: enable UI
    [self refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.remainderManager = [[IRRemainderManager alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessGranted:)
                                                 name:IRRemainderManagerAccessGrantedNotification
                                               object:self.remainderManager];
    [self.remainderManager requestAccess];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(IBAction)refresh
{
    [self.refreshControl beginRefreshing];

    self.calendars = [self.remainderManager remainderCalendars];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.calendars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CalendarCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    EKCalendar *calendar = self.calendars[indexPath.row];
    
    cell.textLabel.text = calendar.title;
    cell.detailTextLabel.text = calendar.source.title;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowCalendar"])
    {
        IRItemsViewController *vc = segue.destinationViewController;
        vc.calendarIdentifier = [self.calendars[[self.tableView indexPathForCell:sender].row] calendarIdentifier];
    }
}

@end
