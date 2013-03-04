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

+(BOOL)isCalendarIdentifierValid:(NSString*)calendarIdentifier
{
    EKEventStore *store = [[EKEventStore alloc] init];
    return ((calendarIdentifier) && ([store calendarWithIdentifier:calendarIdentifier])) ? YES : NO;
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

#pragma mark - Calendars

-(NSArray*)remainderCalendars
{
    NSArray *calendars;
    if (self.accessGranted)
    {
        calendars = [self.store calendarsForEntityType:EKEntityTypeReminder];
    }
    
    return calendars;
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
        [self.store fetchRemindersMatchingPredicate:[self.store predicateForIncompleteRemindersWithDueDateStarting:nil
                                                                                                            ending:nil
                                                                                                         calendars:@[calendar]]
                                         completion:completionBlock];
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
