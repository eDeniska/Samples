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

@property (nonatomic, readwrite) BOOL accessGranted;
@property (nonatomic, strong) EKEventStore *store;

-(void)resignActive:(NSNotification*)notification;

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
    }
    
    return self;
}

-(void)resignActive:(NSNotification*)notification
{
    self.accessGranted = NO;
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

-(void)requestAccess
{
    if (!self.accessGranted)
    {
        [_store requestAccessToEntityType:EKEntityTypeReminder
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


-(NSArray*)remainderCalendars
{
    NSArray *calendars;
    if (self.accessGranted)
    {
        calendars = [self.store calendarsForEntityType:EKEntityTypeReminder];
    }
    
    return calendars;
}


-(void)fetchRemaindersInCalendar:(EKCalendar*)calendar completion:(IRRemainderFetchCompletionBlock)completionBlock
{
    if (self.accessGranted)
    {
        [self.store fetchRemindersMatchingPredicate:[self.store predicateForIncompleteRemindersWithDueDateStarting:nil
                                                                                                            ending:nil
                                                                                                         calendars:@[calendar]]
                                         completion:completionBlock];
    }
}

@end
