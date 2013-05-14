//
//  INChildThree+Initializers.m
//  Initializers
//
//  Created by Danis Tazetdinov on 14.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "INChildThree+Initializers.h"

@implementation INChildThree (Initializers)

+(void)load
{
    NSLog(@"Class INChildThree with categoty Initializers is loaded");
    fflush(stderr);
}

+(void)initialize
{
    NSLog(@"Class INChildThree with categoty Initializers (%@) is initialized", self);
    fflush(stderr);
}


@end
