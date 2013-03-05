//
//  IRRemaindersViewController.m
//  iRemember
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "IRRemaindersViewController.h"
#import "IRRemainderManager.h"

#define kCalendarIdentifierKey @"CalendarIdentifier"

@interface IRRemaindersViewController () <UIDataSourceModelAssociation>

@property (nonatomic, strong) NSArray *remainders;

-(IBAction)refresh;
-(void)becomeActive:(NSNotification*)notification;

@end

@implementation IRRemaindersViewController


#pragma mark - State restoration

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    DLog(@"encoding %@", self.calendarIdentifier);
    [coder encodeObject:self.calendarIdentifier forKey:kCalendarIdentifierKey];
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
    if ([[IRRemainderManager defaultManager] isCalendarIdentifierValid:calendarIdentifier])
    { 
        IRRemaindersViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IRRemaindersViewController"];
        vc.calendarIdentifier = calendarIdentifier;
        DLog(@"vc is ready %@ (%@)", vc, storyboard);
        return vc;
    }
    else
    {
        return nil;
    }
}

#warning Model identifiers are queried before remainders are fetched
- (NSString *) modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    DLog(@"idx: %@, %@", idx, self.remainders);
    EKReminder *remainder = [self.remainders objectAtIndex:idx.row];
    return remainder.calendarItemIdentifier;
}

- (NSIndexPath *) indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    DLog(@"identifier %@, %@", identifier, self.remainders);
    NSIndexPath * __block indexPath;
    [self.remainders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        EKReminder *remainder = obj;
        if ([remainder.calendarItemIdentifier isEqualToString:identifier])
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
    if (!self.remainders)
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
        [[IRRemainderManager defaultManager] fetchRemaindersInCalendarWithIdentifier:self.calendarIdentifier completion:^(NSArray *remainders) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.remainders = remainders;
                self.navigationItem.rightBarButtonItem.enabled = [IRRemainderManager defaultManager].accessGranted;
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            });
        }];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.remainders = nil;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
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
    return self.remainders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RemainderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    EKReminder *remainder = self.remainders[indexPath.row];
    
    cell.textLabel.text = remainder.title;
    
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
