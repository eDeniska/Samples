//
//  UIActionSheet+BlockHandlers.m
//  Actions
//
//  Created by Danis Tazetdinov on 23.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <objc/objc-runtime.h>
#import "UIActionSheet+BlockHandlers.h"

@implementation UIActionSheet (BlockHandlers) 

#pragma mark - Block handlers storage

-(NSMutableDictionary *)handlers
{
    NSMutableDictionary *_handlers = objc_getAssociatedObject(self, @selector(handlers));
    if (!_handlers)
    {
        _handlers = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(handlers), _handlers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _handlers;
}

#pragma mark - Public methods

-(id)initWithTitle:(NSString *)title
{
    return [self initWithTitle:title
                      delegate:self
             cancelButtonTitle:nil
        destructiveButtonTitle:nil
             otherButtonTitles:nil];
}

-(void)addButtonWithTitle:(NSString*)title
               buttonType:(ASActionSheetButtonType)buttonType
                  handler:(ASActionSheetButtonHanlder)block
{
    self.delegate = self;
    NSInteger index = [self addButtonWithTitle:title];
    if (block)
    {
        self.handlers[@(index)] = [block copy];
    }
    switch (buttonType)
    {
        case ASActionSheetButtonTypeDestructive:
            self.destructiveButtonIndex = index;
            break;
            
        case ASActionSheetButtonTypeCancel:
            self.cancelButtonIndex = index;
            
        default:
            break;
    }
}

#pragma mark - Delegate method

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ASActionSheetButtonHanlder block = self.handlers[@(buttonIndex)];
    if (block)
    {
        block();
    }
}


@end
