//
//  IRRemainderManager.m
//  iRemember
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "IRRemainderManager.h"

NSString * const IRRemainderManagerAccessGrantedNotification = @"IRRemainderManagerAccessGrantedNotification";

@interface IRRemainderManager()

@property (atomic, readwrite) BOOL accessGranted;
@property (nonatomic, strong) EKEventStore *store;

-(void)resignActive:(NSNotification*)notification;
-(void)becomeActive:(NSNotification*)notification;

@end

@implementation IRRemainderManager

+(IRRemainderManager*)defaultManager
{
    static dispatch_once_t onceToken;
    static IRRemainderManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[IRRemainderManager alloc] init];
    });
    return manager;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)resignActive:(NSNotification*)notification
{
    self.accessGranted = NO;
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
                                       self.accessGranted = granted;
                                       if (granted)
                                       {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:IRRemainderManagerAccessGrantedNotification
                                                                                               object:self];
                                       }
                                   }];
    }
}

-(void)requestAccessAndWait
{
    if (!self.accessGranted)
    {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [self.store requestAccessToEntityType:EKEntityTypeReminder
                                   completion:^(BOOL granted, NSError *error) {
                                       self.accessGranted = granted;
                                       if (granted)
                                       {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:IRRemainderManagerAccessGrantedNotification
                                                                                               object:self];
                                       }
                                       dispatch_semaphore_signal(semaphore);
                                   }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}


#pragma mark - Calendars

-(NSArray*)remainderCalendars
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
        
        NSError __autoreleasing *error;
        
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

#pragma mark - Remainder fetch and submit

-(void)fetchRemaindersInCalendarWithIdentifier:(NSString*)calendarIdentifier completion:(IRRemainderFetchCompletionBlock)completionBlock
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

-(EKReminder*)addRemainderWithTitle:(NSString*)title inCalendarWithIdentifier:(NSString*)calendarIdentifier
{
    if (self.accessGranted)
    {
        EKReminder *remainder = [EKReminder reminderWithEventStore:self.store];
        remainder.calendar = [self.store calendarWithIdentifier:calendarIdentifier];
        remainder.title = title;
        
        
        NSError __autoreleasing *error;
        
        if ([self.store saveReminder:remainder commit:YES error:&error])
        {
            return remainder;
        }
        else
        {
            DLog(@"failure saving remainder: %@", error);
        }
    }
    return nil;
}

@end
