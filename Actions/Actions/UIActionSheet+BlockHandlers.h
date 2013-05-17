//
//  UIActionSheet+BlockHandlers.h
//  Actions
//
//  Created by Danis Tazetdinov on 23.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ASActionSheetButtonHanlder)();

@interface UIActionSheet (BlockHandlers) <UIActionSheetDelegate>

-(id)initWithTitle:(NSString *)title;

-(void)addButtonWithTitle:(NSString*)title
                  handler:(ASActionSheetButtonHanlder)block;

-(void)addDestructiveButtonWithTitle:(NSString*)title
                             handler:(ASActionSheetButtonHanlder)block;

-(void)addCancelButtonWithTitle:(NSString*)title
                        handler:(ASActionSheetButtonHanlder)block;


@end
