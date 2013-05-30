//
//  INViewController.m
//  Introspector
//
//  Created by Danis Tazetdinov on 30.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "INViewController.h"
#import "NSObject+Introspector.h"

@interface INViewController ()

@property (nonatomic, strong) NSArray *internalArray;

@end

@interface INViewController(Categorised)

@property (atomic, weak) NSMutableArray *categorizedArray;

@end

@implementation INViewController(Categorised)

-(NSMutableArray *)categorizedArray
{
    return [self.internalArray mutableCopy];
}

-(void)setCategorizedArray:(NSMutableArray *)categorizedArray
{
    self.internalArray = categorizedArray;
}

@end

@implementation INViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"this is:\n%@", [self objectDescription]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
