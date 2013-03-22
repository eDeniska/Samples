//
//  RMReminderManager.m
//  Remind Me At
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "RMReminderManager.h"

NSString * const RMReminderManagerAccessGrantedNotification = @"RMReminderManagerAccessGrantedNotification";
NSString * const RMReminderManagerReminderUpdatedNotification = @"RMReminderManagerReminderUpdatedNotification";

@interface RMReminderManager()

@property (nonatomic, strong) EKEventStore *store;

-(void)becomeActive:(NSNotification*)notification;

@end

@implementation RMReminderManager

+(instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    static RMReminderManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[RMReminderManager alloc] init];
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
                                           [[NSNotificationCenter defaultCenter] postNotificationName:RMReminderManagerAccessGrantedNotification
                                                                                               object:self];
                                       }
                                       if (error)
                                       {
                                           NSLog(@"failure requesting access: %@", error);
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
                                           [[NSNotificationCenter defaultCenter] postNotificationName:RMReminderManagerAccessGrantedNotification
                                                                                               object:self];
                                       }
                                       if (error)
                                       {
                                           NSLog(@"failure requesting access: %@", error);
                                       }
                                   }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}


#pragma mark - Calendars

-(EKCalendar*)defaultReminderCalendar
{
    return self.accessGranted ? [self.store defaultCalendarForNewReminders] : nil;
}

-(EKCalendar*)calendarWithIdentifier:(NSString*)identifier
{
    return self.accessGranted ? [self.store calendarWithIdentifier:identifier] : nil;
}


#pragma mark - Reminder fetch and submit

-(void)fetchGeofencedRemindersWithCompletion:(RMReminderFetchCompletionBlock)completionBlock
{
    if (self.accessGranted)
    {
        if (completionBlock)
        {
            RMReminderFetchCompletionBlock completion = [completionBlock copy];
            
            NSPredicate *predicate = [self.store predicateForIncompleteRemindersWithDueDateStarting:nil
                                                                                             ending:nil
                                                                                          calendars:nil];
            
            [self.store fetchRemindersMatchingPredicate:predicate completion:^(NSArray * reminders) {
                // now looking for
                NSMutableArray *array = [NSMutableArray array];
                for (EKReminder *reminder in reminders)
                {
                    BOOL hasGeofencedAlarm = NO;
                    for (EKAlarm *alarm in reminder.alarms)
                    {
                        if ((alarm.structuredLocation) &&
                            ((alarm.proximity == EKAlarmProximityLeave) || (alarm.proximity == EKAlarmProximityEnter)))
                        {
                            hasGeofencedAlarm = YES;
                            break;
                        }
                    }
                    if (hasGeofencedAlarm)
                    {
                        [array addObject:reminder];
                    }
                }
                
                completion(array);
            }];
        }
    }
    else if (completionBlock)
    {
        completionBlock(nil);
    }
}

-(void)addReminderWithAnnotation:(RMGeofencedReminderAnnotation*)annotation
        inCalendarWithIdentifier:(NSString*)calendarIdentifier
                      completion:(RMReminderAddCompletionBlock)completionBlock;
{
    if (self.accessGranted)
    {
        RMReminderAddCompletionBlock completion = [completionBlock copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EKReminder *reminder = [EKReminder reminderWithEventStore:self.store];
            reminder.calendar = [self.store calendarWithIdentifier:calendarIdentifier];
            reminder.title = annotation.title;
            
            EKAlarm *alarm = [[EKAlarm alloc] init];
            alarm.proximity = annotation.proximity;
            alarm.structuredLocation = [EKStructuredLocation locationWithTitle:annotation.subtitle];
            alarm.structuredLocation.geoLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
                                                                              longitude:annotation.coordinate.longitude];
            alarm.structuredLocation.radius = 0.0f;
            
            reminder.alarms = @[ alarm ];
            
            NSError * __autoreleasing error;
            
            if (![self.store saveReminder:reminder commit:YES error:&error])
            {
                NSLog(@"failure saving reminder: %@", error);
            }
            if (completion)
            {
                completion(reminder);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:RMReminderManagerReminderUpdatedNotification
                                                                object:self];
        });
    }
    else if (completionBlock)
    {
        completionBlock(nil);
    }
}


-(void)saveReminder:(EKReminder*)reminder withCompletion:(RMReminderOperationCompletionBlock)completionBlock
{
    if (self.accessGranted)
    {
        RMReminderOperationCompletionBlock completion = [completionBlock copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * __autoreleasing error;
            
            BOOL result = [self.store saveReminder:reminder commit:YES error:&error];
            if (!result)
            {
                NSLog(@"failure saving reminder: %@", error);
            }
            if (completion)
            {
                completion(result);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:RMReminderManagerReminderUpdatedNotification
                                                                object:self];
        });
    }
    else if (completionBlock)
    {
        completionBlock(NO);
    }
}

-(void)removeReminder:(EKReminder*)reminder withCompletion:(RMReminderOperationCompletionBlock)completionBlock
{
    if (self.accessGranted)
    {
        RMReminderOperationCompletionBlock completion = [completionBlock copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * __autoreleasing error;
            
            BOOL result = [self.store removeReminder:reminder commit:YES error:&error];
            if (!result)
            {
                NSLog(@"failure deleting reminder: %@", error);
            }
            if (completion)
            {
                completion(result);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:RMReminderManagerReminderUpdatedNotification
                                                                object:self];
        });
    }
    else if (completionBlock)
    {
        completionBlock(NO);
    }
}


@end
