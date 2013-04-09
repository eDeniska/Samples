//
//  TSViewController.m
//  TouchSize
//
//  Created by Danis Tazetdinov on 08.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "TSViewController.h"
#import "TSTouchView.h"

@interface TSViewController () <TSTouchViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *touchInfo;
@property (weak, nonatomic) IBOutlet TSTouchView *touchArea;

@property (assign, nonatomic) float minTouch;
@property (assign, nonatomic) float maxTouch;
@property (assign, nonatomic) float currentTouch;

@end

@implementation TSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.touchArea.delegate = self;
    [self updateInfoLabel];
}

-(void)updateInfoLabel
{
    if ((self.minTouch) || (self.maxTouch))
    {
        self.touchInfo.text = [NSString stringWithFormat:@"Touch %.2f [%.2f .. %.2f]", self.currentTouch, self.minTouch, self.maxTouch];
    }
    else
    {
        self.touchInfo.text = @"No touches";
    }
}

#pragma mark - Touch view delegate

-(void)touchView:(TSTouchView *)sender startedTouchWithSize:(float)touchSize
{
    self.minTouch = touchSize;
    self.maxTouch = touchSize;
    self.currentTouch = touchSize;
    [self updateInfoLabel];
}

-(void)touchView:(TSTouchView *)sender movedTouchWithSize:(float)touchSize
{
    if (self.minTouch > touchSize)
    {
        self.minTouch = touchSize;
    }
    
    if (self.maxTouch < touchSize)
    {
        self.maxTouch = touchSize;
    }
    self.currentTouch = touchSize;
    [self updateInfoLabel];
}

-(void)touchViewEndedTouch:(TSTouchView *)sender
{
    
}

@end
