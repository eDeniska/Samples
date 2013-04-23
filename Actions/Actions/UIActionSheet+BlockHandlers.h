//
//  UIActionSheet+BlockHandlers.h
//  Actions
//
//  Created by Danis Tazetdinov on 23.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ASActionSheetButtonHanlder)();

typedef NS_ENUM(NSUInteger, ASActionSheetButtonType)
{
    ASActionSheetButtonTypeDefault     = 0,
    ASActionSheetButtonTypeDestructive = 1,
    ASActionSheetButtonTypeCancel      = 2
};

@interface UIActionSheet (BlockHandlers) <UIActionSheetDelegate>

-(id)initWithTitle:(NSString *)title;

-(void)addButtonWithTitle:(NSString*)title
               buttonType:(ASActionSheetButtonType)buttonType
                  handler:(ASActionSheetButtonHanlder)block;


@end
