//
//  IMViewController.m
//  ImageManage
//
//  Created by Danis Tazetdinov on 06.02.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "IMViewController.h"
#import "IMStoredImage.h"

@interface IMViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageAlpha;
@property (weak, nonatomic) IBOutlet UIImageView *imageNoAlpha;


@end

@implementation IMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    IMStoredImage *alphaImage = [[IMStoredImage alloc] initWithImage:[UIImage imageNamed:@"imageAlpha.png"]];
    IMStoredImage *noAlphaImage = [[IMStoredImage alloc] initWithImage:[UIImage imageNamed:@"imageNoAlpha.jpg"]];
    
    NSLog(@"alpha image: %@", alphaImage);
    NSLog(@"no alpha image: %@", noAlphaImage);
    
    self.imageAlpha.image = alphaImage.image;
    self.imageNoAlpha.image = noAlphaImage.image;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
