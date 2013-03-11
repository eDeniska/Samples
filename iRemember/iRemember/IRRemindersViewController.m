//
//  IRRemindersViewController.m
//  iRemember
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "IRRemindersViewController.h"
#import "IRReminderManager.h"

#define kCalendarIdentifierKey @"CalendarIdentifier"

@interface IRRemindersViewController () <UIDataSourceModelAssociation, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *reminders;

-(IBAction)refresh;
-(IBAction)addReminder;
-(void)becomeActive:(NSNotification*)notification;

@end

@implementation IRRemindersViewController


#pragma mark - State restoration

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    DLog(@"encoding %@", self.calendarIdentifier);
    if (self.calendarIdentifier)
    {
        [coder encodeObject:self.calendarIdentifier forKey:kCalendarIdentifierKey];
    }
    [super encodeRestorableStateWithCoder:coder];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.calendarIdentifier = [coder decodeObjectForKey:kCalendarIdentifierKey];
    DLog(@"decoded %@", self.calendarIdentifier);
}

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIStoryboard *storyboard = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    NSString *calendarIdentifier = [coder decodeObjectForKey:kCalendarIdentifierKey];
    DLog(@"about to restore VC with %@, %@", calendarIdentifier, identifierComponents);
    if ([[IRReminderManager defaultManager] isCalendarIdentifierValid:calendarIdentifier])
    { 
        IRRemindersViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IRRemindersViewController"];
        vc.calendarIdentifier = calendarIdentifier;
        DLog(@"vc is ready %@ (%@)", vc, storyboard);
        return vc;
    }
    else
    {
        return nil;
    }
}

#warning Model identifiers are queried before reminders are fetched
- (NSString *) modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    DLog(@"idx: %@, %@", idx, self.reminders);
    EKReminder *reminder = [self.reminders objectAtIndex:idx.row];
    return reminder.calendarItemIdentifier;
}

- (NSIndexPath *) indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    DLog(@"identifier %@, %@", identifier, self.reminders);
    NSIndexPath * __block indexPath;
    [self.reminders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        EKReminder *reminder = obj;
        if ([reminder.calendarItemIdentifier isEqualToString:identifier])
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
    
    self.restorationClass = [self class];

    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (!self.reminders)
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

#warning Calendar identifier could be invalid
    if (self.calendarIdentifier)
    {
        [[IRReminderManager defaultManager] fetchRemindersInCalendarWithIdentifier:self.calendarIdentifier completion:^(NSArray *reminders) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.reminders = reminders;
                self.navigationItem.rightBarButtonItem.enabled = [IRReminderManager defaultManager].accessGranted;
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            });
        }];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.reminders = nil;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
}

-(IBAction)addReminder
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add reminder", @"Add reminder title")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                              otherButtonTitles:NSLocalizedString(@"Add", @"Add button"), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"Item title", @"Item title placeholder");
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSString *title = [alertView textFieldAtIndex:0].text;
        [[IRReminderManager defaultManager] addReminderWithTitle:title inCalendarWithIdentifier:self.calendarIdentifier completion:^(EKReminder *reminder) {
            if (reminder)
            {
                self.reminders = [self.reminders arrayByAddingObject:reminder];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.reminders.count - 1) inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
        }];
    }
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
    return self.reminders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReminderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    EKReminder *reminder = self.reminders[indexPath.row];
    
//    cell.textLabel.text = reminder.title;
//    cell.textLabel.textColor = reminder.completed ? [UIColor lightGrayColor] : [UIColor blackColor];
    NSDictionary *attributes = reminder.completed ? @{ NSStrikethroughStyleAttributeName : @YES } : @{};
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:reminder.title attributes:attributes];
    
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
        
        EKReminder *reminder = self.reminders[indexPath.row];
        [[IRReminderManager defaultManager] removeReminder:reminder withCompletion:^(BOOL result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result)
                {
                    NSMutableArray *reminders = [self.reminders mutableCopy];
                    [reminders removeObjectAtIndex:indexPath.row];
                    self.reminders = [reminders copy];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
#warning Signal if delete fails
            });
        }];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EKReminder *reminder = self.reminders[indexPath.row];
    reminder.completed = !reminder.completed;
    [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[IRReminderManager defaultManager] saveReminder:reminder withCompletion:^(BOOL result) {
        if (!result)
        {
#warning Signal if save fails
        }
    }];
}


@end
