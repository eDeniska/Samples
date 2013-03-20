//
//  RMMapViewController.m
//  Remind Me At
//
//  Created by Danis Tazetdinov on 18.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "RMMapViewController.h"
#import <MapKit/MapKit.h>
#import "RMGeofencedReminderAnnotation.h"
#import "RMAddReminderViewController.h"
#import "RMShowReminderViewController.h"
#import "RMReminderManager.h"
#import <AddressBookUI/AddressBookUI.h>

@interface RMMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

-(IBAction)saveReminder:(UIStoryboardSegue*)segue;
-(IBAction)longPress:(UILongPressGestureRecognizer*)recognizer;

-(void)remindersUpdated:(NSNotification*)notification;
-(void)becomeActive:(NSNotification*)notification;

@property (strong, nonatomic) RMGeofencedReminderAnnotation *addedReminderAnnotation;
@property (strong, nonatomic) CLGeocoder *geocoger;

@property (strong, nonatomic) NSArray *reminderAnnotations;

@end

@implementation RMMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.geocoger = [[CLGeocoder alloc] init];
    self.navigationItem.rightBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;

    [self fetchReminders];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remindersUpdated:) name:RMReminderManagerReminderUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

-(void)remindersUpdated:(NSNotification*)notification
{
    [self fetchReminders];
}

-(void)becomeActive:(NSNotification*)notification
{
    [self fetchReminders];
}

#pragma mark - Actions

-(IBAction)saveReminder:(UIStoryboardSegue*)segue
{
    // controller is dismissed automatically
    
    [self.mapView removeAnnotation:self.addedReminderAnnotation];
    self.addedReminderAnnotation = nil;
}


-(IBAction)longPress:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[recognizer locationInView:self.mapView] toCoordinateFromView:self.mapView];
        if (self.addedReminderAnnotation)
        {
            [self.mapView removeAnnotation:self.addedReminderAnnotation];
        }
        self.addedReminderAnnotation = [[RMGeofencedReminderAnnotation alloc] initWithCoordiate:coordinate
                                                                                          title:NSLocalizedString(@"New reminder here", @"New reminder placeholder")
                                                                                       subtitle:nil];
        [self.mapView addAnnotation:self.addedReminderAnnotation];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self.geocoger reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if ((placemarks) && (!error))
            {
                CLPlacemark *placemark = [placemarks lastObject];
                self.addedReminderAnnotation.subtitle = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            }
        }];
    }
}

#pragma mark - Reminders

-(void)fetchReminders
{
    [[RMReminderManager defaultManager] fetchGeofencedRemindersWithCompletion:^(NSArray *reminders) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.reminderAnnotations)
            {
                [self.mapView removeAnnotations:self.reminderAnnotations];
            }
            
            NSMutableArray *annotations = [NSMutableArray array];
            for (EKReminder *reminder in reminders)
            {
                for (EKAlarm *alarm in reminder.alarms)
                {
                    if (alarm.structuredLocation)
                    {
                        RMGeofencedReminderAnnotation *annotation = [[RMGeofencedReminderAnnotation alloc] initWithCoordiate:alarm.structuredLocation.geoLocation.coordinate
                                                                                                                       title:reminder.title
                                                                                                                    subtitle:alarm.structuredLocation.title];
                        annotation.isFetched = YES;
                        annotation.reminder = reminder;
                        [annotations addObject:annotation];
                        break;
                    }
                }
            }
            self.reminderAnnotations = annotations;
            [self.mapView addAnnotations:self.reminderAnnotations];
        });
    }];
}


#pragma mark - Map view delegate methods

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[RMGeofencedReminderAnnotation class]])
    {
        RMGeofencedReminderAnnotation *annotation = (RMGeofencedReminderAnnotation*)view.annotation;
        if (annotation.isFetched)
        {
            [self performSegueWithIdentifier:@"ShowReminder" sender:view];
        }
        else
        {
            [self performSegueWithIdentifier:@"AddReminder" sender:view];
        }
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[RMGeofencedReminderAnnotation class]])
    {
        static NSString *reminderAnnotationIdentifier = @"ReminderAnnotation";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reminderAnnotationIdentifier];
        if (!annotationView)
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reminderAnnotationIdentifier];
            annotationView.canShowCallout = YES;
        }
        else
        {
            annotationView.annotation = annotation;
        }
        RMGeofencedReminderAnnotation *geofencedReminder = (RMGeofencedReminderAnnotation *)annotation;
        annotationView.pinColor = geofencedReminder.isFetched ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;
        annotationView.rightCalloutAccessoryView =  geofencedReminder.isFetched ? [UIButton buttonWithType:UIButtonTypeDetailDisclosure] :
                                                                                  [UIButton buttonWithType:UIButtonTypeContactAdd];
        annotationView.animatesDrop = !geofencedReminder.isFetched;
        
        return annotationView;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddReminder"])
    {
        RMAddReminderViewController *vc = segue.destinationViewController;
        MKAnnotationView *view = (MKAnnotationView *)sender;
        vc.reminderAnnotation = (RMGeofencedReminderAnnotation*)view.annotation;
    }
    else if ([segue.identifier isEqualToString:@"ShowReminder"])
    {
        RMShowReminderViewController *vc = segue.destinationViewController;
        MKAnnotationView *view = (MKAnnotationView *)sender;
        RMGeofencedReminderAnnotation*annotation = (RMGeofencedReminderAnnotation*)view.annotation;
        vc.reminder = annotation.reminder;
        
        vc.deleteReminderCompletion = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        };
    }
}


@end
