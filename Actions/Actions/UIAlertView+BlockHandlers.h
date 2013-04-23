//
//  UIAlertView+BlockHandlers.h
//  Actions
//
//  Created by Danis Tazetdinov on 23.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ASAlertViewButtonHandler)();

typedef NS_ENUM(NSUInteger, ASAlertViewButtonType)
{
    ASAlertViewButtonTypeDefault = 0,
    ASAlertViewButtonTypeCancel  = 1
};

@interface UIAlertView (BlockHandlers) <UIAlertViewDelegate>

-(id)initWithTitle:(NSString *)title message:(NSString*)message;

-(void)addButtonWithTitle:(NSString*)title
               buttonType:(ASAlertViewButtonType)buttonType
                  handler:(ASAlertViewButtonHandler)block;

@end
