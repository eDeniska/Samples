//
//  IRReminderManager.m
//  iRemember
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "IRReminderManager.h"

NSString * const IRReminderManagerAccessGrantedNotification = @"IRReminderManagerAccessGrantedNotification";

@interface IRReminderManager()

@property (nonatomic, strong) EKEventStore *store;

-(void)becomeActive:(NSNotification*)notification;

@end

@implementation IRReminderManager

+(instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    static IRReminderManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[IRReminderManager alloc] init];
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)becomeActive:(NSNotification*)notification
{
    [self requestAccess];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(EKEventStore *)store
{
    if (!_store)
    {
        _store = [[EKEventStore alloc] init];
    }
    return _store;
}

#pragma mark - Verification methods

-(BOOL)isCalendarIdentifierValid:(NSString*)calendarIdentifier
{
    return ((self.accessGranted) && (calendarIdentifier) && ([self.store calendarWithIdentifier:calendarIdentifier]));
}

#pragma mark - Access management

-(void)requestAccess
{
    if (!self.accessGranted)
    {
        [self.store requestAccessToEntityType:EKEntityTypeReminder
                                   completion:^(BOOL granted, NSError *error) {
                                       if (granted)
                                       {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:IRReminderManagerAccessGrantedNotification
                                                                                               object:self];
                                       }
                                       if (error)
                                       {
                                           DLog(@"failure requesting access: %@", error);
                                       }
                                   }];
    }
}

-(BOOL)accessGranted
{
    return ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] == EKAuthorizationStatusAuthorized);
}

-(void)requestAccessAndWait
{
    if (!self.accessGranted)
    {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [self.store requestAccessToEntityType:EKEntityTypeReminder
                                   completion:^(BOOL granted, NSError *error) {
                                       dispatch_semaphore_signal(semaphore);
                                       if (granted)
                                       {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:IRReminderManagerAccessGrantedNotification
                                                                                               object:self];
                                       }
                                       if (error)
                                       {
                                           DLog(@"failure requesting access: %@", error);
                                       }
                                   }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}


#pragma mark - Calendars

-(NSArray*)reminderCalendars
{
    return self.accessGranted ? [self.store calendarsForEntityType:EKEntityTypeReminder] : nil;
}

-(NSArray*)sources
{
    return self.accessGranted ? [self.store sources] : nil;
}

-(EKCalendar*)addCalendarWithTitle:(NSString*)title inSourceWithIdentifier:(NSString*)sourceIdentifier
{
    if (self.accessGranted)
    {
        EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.store];
        calendar.title = title;
        calendar.source = [self.store sourceWithIdentifier:sourceIdentifier];
        
        NSError * __autoreleasing error;
        
        if ([self.store saveCalendar:calendar commit:YES error:&error])
        {
            return calendar;
        }
        else
        {
            DLog(@"failure saving calendar: %@", error);
        }
    }
    return nil;
}

#pragma mark - Reminder fetch and submit

-(void)fetchRemindersInCalendarWithIdentifier:(NSString*)calendarIdentifier completion:(IRReminderFetchCompletionBlock)completionBlock
{
    if (self.accessGranted)
    {
        EKCalendar *calendar = [self.store calendarWithIdentifier:calendarIdentifier];
        NSPredicate *predicate = [self.store predicateForIncompleteRemindersWithDueDateStarting:nil
                                                                                         ending:nil
                                                                                      calendars:@[calendar]];

        [self.store fetchRemindersMatchingPredicate:predicate completion:completionBlock];
    }
    else if (completionBlock)
    {
        completionBlock(nil);
    }
}

-(void)addReminderWithTitle:(NSString*)title inCalendarWithIdentifier:(NSString*)calendarIdentifier completion:(IRReminderAddCompletionBlock)completionBlock
{
    if (self.accessGranted)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EKReminder *reminder = [EKReminder reminderWithEventStore:self.store];
            reminder.calendar = [self.store calendarWithIdentifier:calendarIdentifier];
            reminder.title = title;
            
            NSError * __autoreleasing error;
            
            if (![self.store saveReminder:reminder commit:YES error:&error])
            {
                DLog(@"failure saving reminder: %@", error);
            }
            if (completionBlock)
            {
                completionBlock(reminder);
            }
        });
    }
    else if (completionBlock)
    {
        completionBlock(nil);
    }
}

-(void)removeReminder:(EKReminder*)reminder withCompletion:(IRReminderOperationCompletionBlock)completionBlock
{
    if (self.accessGranted)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * __autoreleasing error;
            
            BOOL result = [self.store removeReminder:reminder commit:YES error:&error];
            if (!result)
            {
                DLog(@"failure deleting reminder: %@", error);
            }
            if (completionBlock)
            {
                completionBlock(result);
            }
        });
    }
    else if (completionBlock)
    {
        completionBlock(NO);
    }
}


@end
