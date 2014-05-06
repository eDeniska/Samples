//
//  UIImageView+AnimatedChange.h
//  ImageReplacer
//
//  Created by Danis Tazetdinov on 06.05.14.
//  Copyright (c) 2014 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (AnimatedChange)

-(void)setImage:(UIImage*)image animationDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

@end
