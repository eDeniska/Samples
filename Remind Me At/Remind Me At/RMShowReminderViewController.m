//
//  RMShowReminderViewController.m
//  Remind Me At
//
//  Created by Danis Tazetdinov on 19.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "RMShowReminderViewController.h"
#import "RMReminderManager.h"

@interface RMShowReminderViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *proximityCell;

-(IBAction)deleteReminder;

@end

@implementation RMShowReminderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (EKAlarm *alarm in self.reminder.alarms)
    {
        if (alarm.structuredLocation)
        {
            self.proximityCell.detailTextLabel.text = (alarm.proximity == EKAlarmProximityEnter) ? NSLocalizedString(@"arrival", @"On arrival proximity label") :
                                                                                                   NSLocalizedString(@"departure", @"On departure proximity label");
            return;
        }
    }
}

#pragma mark - Table view datasource and delegate

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.reminder.title;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    for (EKAlarm *alarm in self.reminder.alarms)
    {
        if (alarm.structuredLocation)
        {
            return alarm.structuredLocation.title;
        }
    }
    return nil;
}

#pragma mark - Actions

-(IBAction)deleteReminder
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Delete reminder?", @"Delete reminder title")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                               destructiveButtonTitle:NSLocalizedString(@"Delete reminder", @"Delete reminder button")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Action sheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        // delete reminder
        [[RMReminderManager defaultManager] removeReminder:self.reminder withCompletion:^(BOOL result) {
            if (self.deleteReminderCompletion)
            {
                self.deleteReminderCompletion();
            }
        }];
    }
}



@end
