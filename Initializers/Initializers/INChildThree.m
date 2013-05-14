//
//  INChildThree.m
//  Initializers
//
//  Created by Danis Tazetdinov on 14.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "INChildThree.h"

@implementation INChildThree

+(void)load
{
    NSLog(@"Class INChildThree is loaded");
    fflush(stderr);
}

+(void)initialize
{
    NSLog(@"Class INChildThree (%@) is initialized", self);
    fflush(stderr);
}


@end
