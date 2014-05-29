//
//  UIImageView+AnimatedChange.m
//  ImageReplacer
//
//  Created by Danis Tazetdinov on 06.05.14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import "UIImageView+AnimatedChange.h"

@implementation UIImageView (AnimatedChange)

-(void)setImage:(UIImage*)image animationDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    void (^completionBlock)() = [completion copy];
    
    UIImageView *fadingImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    fadingImageView.alpha = 1.0f;
    fadingImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    fadingImageView.translatesAutoresizingMaskIntoConstraints = YES;
    fadingImageView.contentMode = self.contentMode;
    fadingImageView.image = self.image;
    [self addSubview:fadingImageView];
    self.image = image;

    [UIView animateWithDuration:duration
                     animations:^{
                         fadingImageView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [fadingImageView removeFromSuperview];
                         if (completionBlock)
                         {
                             completionBlock();
                         }
                     }];
}

@end
