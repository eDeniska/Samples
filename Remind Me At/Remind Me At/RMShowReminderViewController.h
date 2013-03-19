//
//  RMShowReminderViewController.h
//  Remind Me At
//
//  Created by Danis Tazetdinov on 19.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

typedef void (^RMShowReminderViewControllerDeleteBlock)();


@interface RMShowReminderViewController : UITableViewController

@property (strong, nonatomic) EKReminder *reminder;
@property (copy, nonatomic) RMShowReminderViewControllerDeleteBlock deleteReminderCompletion;

@end
