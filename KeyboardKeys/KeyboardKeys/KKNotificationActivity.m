//
//  KKNotificationActivity.m
//  KeyboardKeys
//
//  Created by Danis Tazetdinov on 05.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "KKNotificationActivity.h"

@interface KKNotificationActivity()

@property (nonatomic, copy) NSString *item;

@end

@implementation KKNotificationActivity

- (NSString *)activityType
{
    return @"com.demo.Notification";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Notification", @"Notification activity title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"NotificationActivityPad" :
                                                                                       @"NotificationActivityPhone")];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id item in activityItems)
    {
        if ([item isKindOfClass:[NSString class]])
        {
            return YES;
        }
        else if ([item isKindOfClass:[NSAttributedString class]])
        {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSMutableArray *textItems = [NSMutableArray array];
    for (id item in activityItems)
    {
        if ([item isKindOfClass:[NSString class]])
        {
            [textItems addObject:item];
        }
        else if ([item isKindOfClass:[NSAttributedString class]])
        {
            [textItems addObject:[item string]];
        }
    }
    self.item = [textItems componentsJoinedByString:@" "];
}

- (void)performActivity
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
    notification.alertBody = self.item;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.hasAction = YES;
    notification.alertAction = NSLocalizedString(@"View", @"View notification button");
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    self.item = nil;
    [self activityDidFinish:YES];
}

@end
