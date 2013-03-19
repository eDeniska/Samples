//
//  RMAddReminderViewController.h
//  Remind Me At
//
//  Created by Danis Tazetdinov on 18.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RMGeofencedReminderAnnotation.h"

@interface RMAddReminderViewController : UITableViewController

@property (strong, nonatomic) RMGeofencedReminderAnnotation *reminderAnnotation;

@end
