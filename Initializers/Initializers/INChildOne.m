//
//  INChildOne.m
//  Initializers
//
//  Created by Danis Tazetdinov on 14.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "INChildOne.h"

@implementation INChildOne

+(void)load
{
    NSLog(@"Class INChildOne is loaded");
    fflush(stderr);
}

+(void)initialize
{
    NSLog(@"Class INChildOne (%@) is initialized", self);
    fflush(stderr);
}


@end
