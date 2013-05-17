//
//  ASViewController.m
//  Actions
//
//  Created by Danis Tazetdinov on 23.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "ASViewController.h"
#import "UIActionSheet+BlockHandlers.h"
#import "UIAlertView+BlockHandlers.h"
#import "NSMutableString+Transform.h"

@interface ASViewController ()

- (IBAction)showActionSheet;
- (IBAction)showAlertView;

@end

@implementation ASViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSMutableString *string = [NSMutableString stringWithString:@"Привет, мир! Поздравительная открытка от дедушки Мороза!"];
    [string transform:kCFStringTransformToLatin];
    NSLog(@"result 1: %@", string);
    [string transform:kCFStringTransformLatinCyrillic];
    NSLog(@"result 2: %@", string);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Action test", @"Action sheet title")];
    
    [actionSheet addDestructiveButtonWithTitle:NSLocalizedString(@"Destructive", @"Destructive button title")
                                       handler:^{
                                           NSLog(@"Destructive button tapped");
                                       }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Normal 1", @"Normal button 1 title")
                            handler:^{
                                NSLog(@"Normal 1 button tapped");
                            }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Normal 2", @"Normal button 2 title")
                            handler:^{
                                NSLog(@"Normal 2 button tapped");
                            }];
    [actionSheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button title")
                                  handler:^{
                                      NSLog(@"Cancel button tapped");
                                  }];
    [actionSheet showInView:self.view];
}

- (IBAction)showAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert test", @"Alert view title")
                                                        message:NSLocalizedString(@"Choose proper action", @"Alert view message")];

    [alertView addButtonWithTitle:NSLocalizedString(@"Normal", @"Normal button title")
                            handler:^{
                                NSLog(@"Normal button tapped");
                            }];
    [alertView addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button title")
                                handler:^{
                                    NSLog(@"Cancel button tapped");
                                }];
    [alertView show];
}

@end
