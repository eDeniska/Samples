//
//  UIAlertView+BlockHanlders.m
//  Actions
//
//  Created by Danis Tazetdinov on 23.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <objc/objc-runtime.h>
#import "UIAlertView+BlockHandlers.h"

typedef NS_ENUM(NSUInteger, ASAlertViewButtonType)
{
    ASAlertViewButtonTypeDefault = 0,
    ASAlertViewButtonTypeCancel  = 1
};

@implementation UIAlertView (BlockHandlers)

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

-(id)initWithTitle:(NSString *)title message:(NSString*)message
{
    return [self initWithTitle:title
                       message:message
                      delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:nil];
}

-(void)addButtonWithTitle:(NSString*)title
                  handler:(ASAlertViewButtonHandler)block
{
    [self addButtonWithTitle:title buttonType:ASAlertViewButtonTypeDefault handler:block];
}

-(void)addCancelButtonWithTitle:(NSString*)title
                        handler:(ASAlertViewButtonHandler)block
{
    [self addButtonWithTitle:title buttonType:ASAlertViewButtonTypeCancel handler:block];
}

-(void)addButtonWithTitle:(NSString*)title
               buttonType:(ASAlertViewButtonType)buttonType
                  handler:(ASAlertViewButtonHandler)block
{
    self.delegate = self;
    NSInteger index = [self addButtonWithTitle:title];
    if (block)
    {
        self.handlers[@(index)] = [block copy];
    }
    switch (buttonType)
    {
        case ASAlertViewButtonTypeCancel:
            self.cancelButtonIndex = index;
            break;
            
        default:
            break;
    }
}

#pragma mark - Delegate method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ASAlertViewButtonHandler block = self.handlers[@(buttonIndex)];
    if (block)
    {
        block();
    }
}

@end
