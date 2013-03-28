//
//  KKViewController.m
//  KeyboardKeys
//
//  Created by Danis Tazetdinov on 28.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "KKViewController.h"

@interface KKViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation KKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.window.frame.size.width, 44.0f)];
    
    // for UIKeyboardAppearanceAlert - this should be set
    //toolBar.tintColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];
    //toolBar.translucent = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        toolBar.tintColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.64f alpha:1.0f];
    }
    else
    {
        toolBar.tintColor = [UIColor colorWithRed:0.56f green:0.59f blue:0.63f alpha:1.0f];
    }
    toolBar.translucent = NO;

    
    
    toolBar.items = @[ [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                        style:UIBarButtonItemStyleBordered
                                                       target:self
                                                       action:@selector(barButtonAdd:)],
                       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                     target:nil
                                                                     action:nil],
                       [[UIBarButtonItem alloc] initWithTitle:@"Action"
                                                        style:UIBarButtonItemStyleBordered
                                                       target:self
                                                       action:@selector(barButtonAction:)],
                       ];
    
    self.textField.inputAccessoryView = toolBar;
	// Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)barButtonAdd:(id)sender
{
    self.textField.text = [self.textField.text stringByAppendingString:@" add"];
}

-(IBAction)barButtonAction:(id)sender
{
    self.textField.text = [self.textField.text stringByAppendingString:@" action"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
