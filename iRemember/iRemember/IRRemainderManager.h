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

@property (nonatomic, readonly) BOOL accessGranted;

-(void)requestAccess;

-(NSArray*)remainderCalendars;
-(void)fetchRemaindersInCalendar:(EKCalendar*)calendar completion:(IRRemainderFetchCompletionBlock)completionBlock;

@end
