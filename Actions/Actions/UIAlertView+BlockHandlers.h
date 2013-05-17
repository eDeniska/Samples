//
//  UIAlertView+BlockHandlers.h
//  Actions
//
//  Created by Danis Tazetdinov on 23.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ASAlertViewButtonHandler)();

@interface UIAlertView (BlockHandlers) <UIAlertViewDelegate>

-(id)initWithTitle:(NSString *)title message:(NSString*)message;

-(void)addButtonWithTitle:(NSString*)title
                  handler:(ASAlertViewButtonHandler)block;

-(void)addCancelButtonWithTitle:(NSString*)title
                        handler:(ASAlertViewButtonHandler)block;

@end
