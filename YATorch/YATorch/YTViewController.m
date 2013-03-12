//
//  YTViewController.m
//  YATorch
//
//  Created by Danis Tazetdinov on 12.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "YTViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface YTViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *torches;
@property (weak, nonatomic) IBOutlet UISlider *torchLevel;
@property (weak, nonatomic) IBOutlet UIButton *torchOffButton;

@property (strong, nonatomic) NSArray *torchDevices;
@property (weak, nonatomic) AVCaptureDevice *selectedTorch;

- (IBAction)torchOff;
- (IBAction)torchSelected;
- (IBAction)torchLevelChanged;

@end

@implementation YTViewController

-(void)setSelectedTorch:(AVCaptureDevice *)selectedTorch
{
    [_selectedTorch unlockForConfiguration];
    _selectedTorch = selectedTorch;
    NSError * __autoreleasing error;
    if (![self.selectedTorch lockForConfiguration:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot change torch level",
                                                                                      @"Problem setting torch level error title")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay, I'll contact developer",
                                                                                      @"Cannot change torch level button")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *devices = [AVCaptureDevice devices];
    NSMutableArray *torchDevices = [NSMutableArray array];
    [self.torches removeAllSegments];
    for (AVCaptureDevice *device in devices)
    {
        if ((device.hasTorch) && ([device isTorchModeSupported:AVCaptureTorchModeOn]))
        {
            [torchDevices addObject:device];
            [self.torches insertSegmentWithTitle:device.localizedName atIndex:NSIntegerMax animated:NO];
        }
    }
    self.torchDevices = torchDevices;

    if (!self.torchDevices.count)
    {
        self.torches.enabled = NO;
        self.torchLevel.enabled = NO;
        self.torchOffButton.enabled = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No torch found", @"No torch title")
                                                            message:NSLocalizedString(@"This device does not have any torches",
                                                                                      @"No torch message")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok, I'll find other device",
                                                                                      @"No torch button")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        self.selectedTorch = self.torchDevices[0];
        self.torches.selectedSegmentIndex = 0;
    }
}

- (IBAction)torchOff
{
    self.selectedTorch.torchMode = AVCaptureTorchModeOff;
    self.torchLevel.value = 0;
}

- (IBAction)torchSelected
{
    self.selectedTorch.torchMode = AVCaptureTorchModeOff;
    self.selectedTorch = self.torchDevices[self.torches.selectedSegmentIndex];
    self.selectedTorch.torchMode = AVCaptureTorchModeOff;
    self.torchLevel.value = 0;
}

- (IBAction)torchLevelChanged
{
    NSError * __autoreleasing error;
    BOOL torchMode;
    if (self.torchLevel.value)
    {
        torchMode = [self.selectedTorch setTorchModeOnWithLevel:self.torchLevel.value
                                                          error:&error];
    }
    else
    {
        self.selectedTorch.torchMode = AVCaptureTorchModeOff;
        torchMode = YES;
    }
    if (!torchMode)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot change torch level",
                                                                                      @"Problem setting torch level error title")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay, I'll contact developer",
                                                                                      @"Cannot change torch level button")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
