//
//  RMGeofencedReminder.h
//  Remind Me At
//
//  Created by Danis Tazetdinov on 19.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <EventKit/EventKit.h>

@interface RMGeofencedReminderAnnotation : NSObject <MKAnnotation>

-(instancetype)initWithCoordiate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subtitle:(NSString*)subtitle;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) EKAlarmProximity proximity;
@property (nonatomic, assign) BOOL isFetched;

@property (nonatomic, strong) EKReminder *reminder;

@end
