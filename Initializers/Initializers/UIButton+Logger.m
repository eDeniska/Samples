//
//  UIButton+Logger.m
//  Initializers
//
//  Created by Danis Tazetdinov on 14.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "UIButton+Logger.h"
#import <objc/runtime.h>

@implementation UIButton (Logger)

-(void)logAndSetTitle:(NSString *)title forState:(UIControlState)state
{
    NSLog(@"Changing title (%@) of %@ to [%@] for state %d", self.titleLabel.text, self, title, state);
    [self logAndSetTitle:title forState:state];
}

+(void)load
{
    Method setTitleOrig = class_getInstanceMethod(self, @selector(setTitle:forState:));
    Method setTitleLog = class_getInstanceMethod(self, @selector(logAndSetTitle:forState:));
    method_exchangeImplementations(setTitleOrig, setTitleLog);
}

@end
