//
//  INViewController.m
//  Initializers
//
//  Created by Danis Tazetdinov on 14.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "INViewController.h"

#import "INParent.h"

#import "INChildOne.h"

#import "INChildTwo.h"

#import "INChildThree.h"

#import "INChildThree+Initializers.h"

@interface INViewController ()

- (IBAction)createObjects:(UIButton*)sender;

@end

@implementation INViewController

- (IBAction)createObjects:(UIButton*)sender
{
    INParent *parent = [[INParent alloc] init];
    NSLog(@"parent = %@", parent);
    
    INChildOne *childOne = [[INChildOne alloc] init];
    NSLog(@"childOne = %@", childOne);
    
    INChildTwo *childTwo = [[INChildTwo alloc] init];
    NSLog(@"childTwo = %@", childTwo);
    
    INChildThree *childThree = [[INChildThree alloc] init];
    NSLog(@"childThree = %@", childThree);
    
    [sender setTitle:@"Objects created" forState:UIControlStateNormal];
}

@end
