//
//  BLRViewController.m
//  Blurry
//
//  Created by Danis Tazetdinov on 10/02/14.
//  Copyright (c) 2014 Fujitsu Russia GDC. All rights reserved.
//

#import "BLRViewController.h"
#import "UIImage+ImageEffects.h"

@interface BLRViewController ()
@property (weak, nonatomic) IBOutlet UIView *containingView;
@property (weak, nonatomic) IBOutlet UIImageView *bigImage;
@property (weak, nonatomic) IBOutlet UIImageView *croppedImage;

@property (strong, nonatomic) NSCache *imageCache;

@end

@implementation BLRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.containingView.layer.masksToBounds = YES;
    self.containingView.layer.cornerRadius = self.croppedImage.frame.size.height / 2;
    self.imageCache = [[NSCache alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateBlurredImageForInterfaceOrientation:self.interfaceOrientation];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration
{
    UIImageView *oldCroppedImage = self.croppedImage;
    UIImageView *replacingCroppedImage = [[UIImageView alloc] initWithFrame:self.containingView.bounds];
    replacingCroppedImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    replacingCroppedImage.translatesAutoresizingMaskIntoConstraints = YES;
    replacingCroppedImage.alpha = 0.0f;
    [self.containingView insertSubview:replacingCroppedImage aboveSubview:oldCroppedImage];
    self.croppedImage = replacingCroppedImage;
    [self updateBlurredImageForInterfaceOrientation:toInterfaceOrientation];
    [UIView animateWithDuration:duration
                     animations:^{
                         replacingCroppedImage.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         [oldCroppedImage removeFromSuperview];
                     }];
}

-(void)updateBlurredImageForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    UIImage *blurredImage = [self.imageCache objectForKey:@(orientation)];
    if (!blurredImage)
    {
        CGFloat scale = self.view.window.screen.scale;
        if (scale == 0.0f)
        {
            scale = [[[UIApplication sharedApplication].windows firstObject] screen].scale;
        }
        UIGraphicsBeginImageContextWithOptions(self.bigImage.layer.bounds.size, YES, scale);
        [self.bigImage.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropFrame = CGRectMake(self.containingView.frame.origin.x * scale,
                                      self.containingView.frame.origin.y * scale,
                                      self.containingView.frame.size.width * scale,
                                      self.containingView.frame.size.height * scale);
        
        CGImageRef cgCropped = CGImageCreateWithImageInRect(image.CGImage, cropFrame);
        UIImage *cropped = [UIImage imageWithCGImage:cgCropped
                                               scale:scale
                                         orientation:UIImageOrientationUp];
        CFRelease(cgCropped);
        blurredImage = [cropped applyTintEffectWithColor:[UIColor greenColor]];
        [self.imageCache setObject:blurredImage forKey:@(orientation)];
    }
    self.croppedImage.image = blurredImage;
}

@end
