//
//  RMAddReminderViewController.m
//  Remind Me At
//
//  Created by Danis Tazetdinov on 18.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "RMAddReminderViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "RMReminderManager.h"

#define kDefaultCalendarKey @"RMAddReminderViewController.DefaultCalendar"

@interface RMAddReminderViewController () <UITextFieldDelegate, EKCalendarChooserDelegate>

@property (weak, nonatomic) IBOutlet UITextField *reminderTitleField;
@property (weak, nonatomic) IBOutlet UITableViewCell *reminderListCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *reminderArrivalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *reminderDepartureCell;

@property (strong, nonatomic) EKCalendar *calendar;

@end

@implementation RMAddReminderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *calendarIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultCalendarKey];
    if (calendarIdentifier)
    {
        self.calendar = [[RMReminderManager defaultManager] calendarWithIdentifier:calendarIdentifier];
    }
    if (!self.calendar)
    {
        self.calendar = [RMReminderManager defaultManager].defaultReminderCalendar;
    }
    if ((self.reminderAnnotation.proximity != EKAlarmProximityEnter) &&
        (self.reminderAnnotation.proximity != EKAlarmProximityLeave))
    {
        self.reminderAnnotation.proximity = EKAlarmProximityEnter;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.reminderListCell.textLabel.text = self.calendar.title;
    self.reminderListCell.detailTextLabel.text = self.calendar.source.title;
    [self updateProximity];
}

-(void)updateProximity
{
    if (self.reminderAnnotation.proximity == EKAlarmProximityEnter)
    {
        self.reminderArrivalCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.reminderDepartureCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        self.reminderArrivalCell.accessoryType = UITableViewCellAccessoryNone;
        self.reminderDepartureCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - Table view delegate

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return (section == 2) ? self.reminderAnnotation.subtitle : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [self.reminderTitleField becomeFirstResponder];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (indexPath.section == 1)
    {
        EKCalendarChooser *vc = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleSingle
                                                                     displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly
                                                                       entityType:EKEntityTypeReminder
                                                                       eventStore:[RMReminderManager defaultManager].store];
        vc.delegate = self;
        vc.selectedCalendars = [NSSet setWithObject:self.calendar];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.section == 2)
    {
        self.reminderAnnotation.proximity = (indexPath.row == 0) ? EKAlarmProximityEnter : EKAlarmProximityLeave;
        [self updateProximity];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Calendar chooser delegate

-(void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser
{
    self.calendar = [calendarChooser.selectedCalendars anyObject];
    [self.navigationController popViewControllerAnimated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:self.calendar.calendarIdentifier forKey:kDefaultCalendarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Text field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SaveReminder"])
    {
        self.reminderAnnotation.title = self.reminderTitleField.text.length ? self.reminderTitleField.text :
                                                                              NSLocalizedString(@"Reminder", @"New reminder default title");
    }
}


@end
