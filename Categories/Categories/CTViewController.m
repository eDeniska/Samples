//
//  CTViewController.m
//  Categories
//
//  Created by Danis Tazetdinov on 11.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "CTViewController.h"
#import "NSString+HiddenValue.h"

@interface CTViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *textFieldHidden;
- (IBAction)storeShowValues;
- (IBAction)trickyAction:(UIButton *)sender;
- (IBAction)alertText;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabelHidden;

@property (nonatomic, copy) NSString *value;

@end

@implementation CTViewController

- (IBAction)storeShowValues
{
    self.value = self.textField.text;
    self.value.hiddenValue = self.textFieldHidden.text;
    
    self.textLabel.text = self.value;
    self.textLabelHidden.text = self.value.hiddenValue;
}

- (IBAction)trickyAction:(UIButton *)sender
{
    // here will use hidden values a lot
    sender.titleLabel.text.hiddenValue = self.textField.text;
    sender.titleLabel.text.hiddenValue.hiddenValue = self.textFieldHidden.text;
    
    // and now let's get value back
    self.textLabel.text = sender.titleLabel.text.hiddenValue;
    self.textLabelHidden.text = sender.titleLabel.text.hiddenValue.hiddenValue;
    
}

- (IBAction)alertText
{
    [self.textField.text showInAlert];
}


@end
