//
//  IRCalendarsViewController.m
//  iRemember
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "IRCalendarsViewController.h"
#import "IRReminderManager.h"
#import "IRRemindersViewController.h"

#import <EventKitUI/EventKitUI.h>

@interface IRCalendarsViewController () <UIDataSourceModelAssociation>

@property (nonatomic, strong) NSArray *calendars;

-(void)becomeActive:(NSNotification*)notification;

@end

@implementation IRCalendarsViewController

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    DLog(@"coder");
    
    [super encodeRestorableStateWithCoder:coder];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    DLog(@"coder");
}

- (NSString *) modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    DLog(@"idx: %@, %@", idx, self.calendars);
    EKCalendar *calendar = [self.calendars objectAtIndex:idx.row];
    return calendar.calendarIdentifier;
}

- (NSIndexPath *) indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    DLog(@"identifier %@, %@", identifier, self.calendars);
    NSIndexPath * __block indexPath;
    [self.calendars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        EKCalendar *calendar = obj;
        if ([calendar.calendarIdentifier isEqualToString:identifier])
        {
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    
    return indexPath;
}


-(void)becomeActive:(NSNotification*)notification
{
    [self refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (!self.calendars)
    {
        [self refresh];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(IBAction)refresh
{
    [self.refreshControl beginRefreshing];

    self.calendars = [[IRReminderManager defaultManager] reminderCalendars];
    self.navigationItem.rightBarButtonItem.enabled = [IRReminderManager defaultManager].accessGranted;
    
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
    if ([segue.identifier isEqualToString:@"ShowReminders"])
    {
        IRRemindersViewController *vc = segue.destinationViewController;
        vc.calendarIdentifier = [self.calendars[[self.tableView indexPathForCell:sender].row] calendarIdentifier];
    }
}

@end
