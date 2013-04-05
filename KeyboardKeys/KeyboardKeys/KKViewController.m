//
//  KKViewController.m
//  KeyboardKeys
//
//  Created by Danis Tazetdinov on 28.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "KKViewController.h"
#import "KKNotificationActivity.h"

@interface KKViewController () <UITextFieldDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *alertTextField;
@property (strong, nonatomic) UIPopoverController *popover;

-(IBAction)share:(UIBarButtonItem*)sender;

@end

@implementation KKViewController

-(void)configureKeyboardToolbars
{
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                     self.view.window.frame.size.width, 44.0f)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        toolBar.tintColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.64f alpha:1.0f];
    }
    else
    {
        toolBar.tintColor = [UIColor colorWithRed:0.56f green:0.59f blue:0.63f alpha:1.0f];
    }
    toolBar.translucent = NO;
    toolBar.items =   @[ [[UIBarButtonItem alloc] initWithTitle:@"!"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"@"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"#"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"$"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"%"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"^"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"&"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"*"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"("
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@")"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonAddText:)],
                         ];
    
    self.textField.inputAccessoryView = toolBar;
    
    // toolbar for alert keyboard appearance, not so nice though
    UIToolbar *alertToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                          self.view.window.frame.size.width, 44.0f)];
    
    alertToolBar.tintColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];
    alertToolBar.translucent = YES;
    alertToolBar.items =  @[ [[UIBarButtonItem alloc] initWithTitle:@"1"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"2"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"3"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"4"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"5"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"6"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"7"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"8"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"9"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"0"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             ];
    
    self.alertTextField.inputAccessoryView = alertToolBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // toolbar for default keyboard appearance
    [self configureKeyboardToolbars];
}

-(IBAction)barButtonAddText:(UIBarButtonItem*)sender
{
    if (self.textField.isFirstResponder)
    {
        [self.textField insertText:sender.title];
    }
    else if (self.alertTextField.isFirstResponder)
    {
        [self.alertTextField insertText:sender.title];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(IBAction)share:(UIBarButtonItem*)sender
{
    // workaround for UIActivityViewController vs keyboard bugs
    [self.textField resignFirstResponder];
    [self.alertTextField resignFirstResponder];

    // prepeare item for sharing
    NSArray *items = @[ self.textField.text,
                        [NSURL URLWithString:@"http://easyplace.wordress.com"],
                        [UIImage imageNamed:@"KeyboardKeysPad@2x.png"] ];
    
    KKNotificationActivity *notificationActivity = [[KKNotificationActivity alloc] init];
    
    // prepare sharing controller
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                      applicationActivities:@[ notificationActivity ]];
    avc.excludedActivityTypes = @[ UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll ];
    avc.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (completed)
        {
            NSLog(@"shared to %@", activityType);
        }
        else
        {
            NSLog(@"not shared");
        }
        
        // workaround for UIActivityViewController vs keyboard bugs
        [self configureKeyboardToolbars];
    };

    // present sharing options to user
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = [[UIPopoverController alloc] initWithContentViewController:avc];
        [self.popover presentPopoverFromBarButtonItem:sender
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
        self.popover.passthroughViews = nil;
        self.popover.delegate = self;
    }
    else
    {
        [self presentViewController:avc animated:YES completion:NULL];
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

@end
