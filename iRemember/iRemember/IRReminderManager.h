//
//  IRReminderManager.h
//  iRemember
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

typedef void (^IRReminderFetchCompletionBlock)(NSArray *reminders);
typedef void (^IRReminderAddCompletionBlock)(EKReminder *reminder);
typedef void (^IRReminderOperationCompletionBlock)(BOOL result);

extern NSString * const IRReminderManagerAccessGrantedNotification;

@interface IRReminderManager : NSObject

// singleton

+(IRReminderManager*)defaultManager;


// Access to reminders

@property (atomic, readonly) BOOL accessGranted;
-(void)requestAccess;
-(void)requestAccessAndWait;


// Verification methods

-(BOOL)isCalendarIdentifierValid:(NSString*)calendarIdentifier;


// Fetch and add reminders

-(void)fetchRemindersInCalendarWithIdentifier:(NSString*)identifier completion:(IRReminderFetchCompletionBlock)completionBlock;
-(void)addReminderWithTitle:(NSString*)title inCalendarWithIdentifier:(NSString*)calendarIdentifier completion:(IRReminderAddCompletionBlock)completionBlock;
-(void)removeReminder:(EKReminder*)reminder withCompletion:(IRReminderOperationCompletionBlock)completionBlock;
-(void)saveReminder:(EKReminder*)reminder withCompletion:(IRReminderOperationCompletionBlock)completionBlock;


// Sources, calendars

-(NSArray*)sources;
-(NSArray*)reminderCalendars;
-(EKCalendar*)addCalendarWithTitle:(NSString*)title inSourceWithIdentifier:(NSString*)sourceIdentifier;

@end
