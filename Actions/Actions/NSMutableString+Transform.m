//
//  NSMutableString+Transform.m
//  Actions
//
//  Created by Danis Tazetdinov on 16.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "NSMutableString+Transform.h"

@implementation NSMutableString (Transform)

-(BOOL)transform:(CFStringRef)transform
{
    return [self transform:transform range:NSMakeRange(0, self.length) reverse:NO];
}

-(BOOL)transform:(CFStringRef)transform range:(NSRange)range reverse:(BOOL)reverse
{
    CFRange cfRange = CFRangeMake(range.location, range.length);
    return (BOOL)CFStringTransform((__bridge CFMutableStringRef)self, &cfRange, transform, (Boolean)reverse);
}

@end
