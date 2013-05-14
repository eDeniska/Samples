//
//  INParent.m
//  Initializers
//
//  Created by Danis Tazetdinov on 14.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "INParent.h"

@implementation INParent

+(void)load
{
    NSLog(@"Class INParent is loaded");
    fflush(stderr);
}

+(void)initialize
{
    NSLog(@"Class INParent (%@) is initialized", self);
    fflush(stderr);
}

@end
