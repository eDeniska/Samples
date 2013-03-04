//
//  IRRemainderManager.h
//  iRemember
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

extern NSString * const IRRemainderManagerAccessGrantedNotification;

typedef void (^IRRemainderFetchCompletionBlock)(NSArray *remainders);

@interface IRRemainderManager : NSObject

@property (atomic, readonly) BOOL accessGranted;

-(void)requestAccess;

-(NSArray*)remainderCalendars;
-(void)fetchRemaindersInCalendarWithIdentifier:(NSString*)identifier completion:(IRRemainderFetchCompletionBlock)completionBlock;

-(NSArray*)sources;
-(void)addCalendarWithTitle:(NSString*)title inSourceWithIdentifier:(NSString*)sourceIdentifier;

@end
