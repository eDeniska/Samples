//
//  IMRViewController.m
//  ImageReplacer
//
//  Created by Danis Tazetdinov on 06.05.14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "IMRViewController.h"
#import "UIImageView+AnimatedChange.h"

@interface IMRViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) NSInteger currentImage;

@end

@implementation IMRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.images = @[ @"rain-01.jpg", @"rain-02.jpg", @"rain-03.jpg" ];
    self.imageView.image = [UIImage imageNamed:self.images[self.currentImage]];
}

-(IBAction)changeImage:(id)sender
{
    self.currentImage++;
    if (self.currentImage >= self.images.count)
    {
        self.currentImage = 0;
    }
    [self.imageView setImage:[UIImage imageNamed:self.images[self.currentImage]]
           animationDuration:0.3f
                  completion:NULL];
}

@end
