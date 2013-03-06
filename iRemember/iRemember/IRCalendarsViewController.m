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

@property (nonatomic, strong) NSArray *sources;
@property (nonatomic, strong) NSDictionary *calendars;

-(void)becomeActive:(NSNotification*)notification;
-(void)accessGranted:(NSNotification*)notification;

@end

@implementation IRCalendarsViewController

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    [self fillCalendars];
}

- (NSString *) modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    DLog(@"idx: %@, %@", idx, self.calendars);
    EKCalendar *calendar = self.calendars[[self.sources[idx.section] sourceIdentifier]] [idx.row];
    return calendar.calendarIdentifier;
}

- (NSIndexPath *) indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    DLog(@"identifier %@, %@", identifier, self.calendars);
    NSIndexPath * __block indexPath;
    [self.sources enumerateObjectsUsingBlock:^(id obj, NSUInteger sourceIdx, BOOL *sourceStop) {
        EKSource *source = obj;
        [self.calendars[source.sourceIdentifier] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            EKCalendar *calendar = obj;
            if ([calendar.calendarIdentifier isEqualToString:identifier])
            {
                indexPath = [NSIndexPath indexPathForRow:idx inSection:sourceIdx];
                *stop = YES;
                *sourceStop = YES;
            }
        }];
    }];
    
    return indexPath;
}

-(void)becomeActive:(NSNotification*)notification
{
    [self refresh];
}

-(void)accessGranted:(NSNotification*)notification
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessGranted:)
                                                 name:IRReminderManagerAccessGrantedNotification
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

-(void)fillCalendars
{
    NSMutableArray *sources = [NSMutableArray array];
    NSArray *calendarsArray = [[IRReminderManager defaultManager] reminderCalendars];
    NSMutableDictionary *calendars = [NSMutableDictionary dictionary];
    [calendarsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        EKCalendar *calendar = obj;
        NSMutableArray *calendarsForSource = calendars[calendar.source.sourceIdentifier];
        if (!calendarsForSource)
        {
            calendarsForSource = [NSMutableArray array];
        }
        if (![sources containsObject:calendar.source])
        {
            [sources addObject:calendar.source];
        }
        [calendarsForSource addObject:calendar];
        calendars[calendar.source.sourceIdentifier] = calendarsForSource;
    }];
    self.sources = sources;
    self.calendars = calendars;
}

-(IBAction)refresh
{
    [self.refreshControl beginRefreshing];

    [self fillCalendars];
    
    self.navigationItem.rightBarButtonItem.enabled = [IRReminderManager defaultManager].accessGranted;
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.calendars[[self.sources[section] sourceIdentifier]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CalendarCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    EKCalendar *calendar = self.calendars[[self.sources[indexPath.section] sourceIdentifier]] [indexPath.row];
    
    cell.textLabel.text = calendar.title;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sources[section] title];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert)
//    {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowReminders"])
    {
        IRRemindersViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        vc.calendarIdentifier = [self.calendars[[self.sources[indexPath.section] sourceIdentifier]] [indexPath.row] calendarIdentifier];
    }
}

@end
