//
//  NSString+HiddenValue.m
//  Categories
//
//  Created by Danis Tazetdinov on 11.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <objc/objc-runtime.h>

#import "NSString+HiddenValue.h"

@implementation NSString (HiddenValue)

-(void)showInAlert
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Debug", @"Debug title")
                                message:self
                               delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok button title") otherButtonTitles:nil] show];
}


-(void)setHiddenValue:(NSString *)hiddenValue
{
    objc_setAssociatedObject(self, @selector(hiddenValue), hiddenValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)hiddenValue
{
    return objc_getAssociatedObject(self, @selector(hiddenValue));
}

@end
