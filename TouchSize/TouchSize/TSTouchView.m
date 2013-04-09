//
//  TSTouchView.m
//  TouchSize
//
//  Created by Danis Tazetdinov on 08.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TSTouchView.h"

CGFloat const kTSTouchViewMultiplyFactor = 10.0f;

@interface TSTouchView()

@property (strong, nonatomic) NSSet *touches;
@property (strong, nonatomic) UIImage *currentDrawing;

@end

@implementation TSTouchView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    self.touches = [touches copy];
    [self setNeedsDisplay];
    
    [self.delegate touchView:self startedTouchWithSize:[[anyTouch valueForKey:@"pathMajorRadius"] floatValue]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    self.touches = [touches copy];
    [self setNeedsDisplay];
    
    [self.delegate touchView:self movedTouchWithSize:[[anyTouch valueForKey:@"pathMajorRadius"] floatValue]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchViewEndedTouch:self];
    self.touches = nil;
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchViewEndedTouch:self];
    self.touches = nil;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    [[UIColor redColor] setFill];
    for (UITouch *touch in self.touches)
    {
        CGPoint p = [touch locationInView:self];
        CGFloat size = [[touch valueForKey:@"pathMajorRadius"] floatValue] * kTSTouchViewMultiplyFactor;
        CGContextFillEllipseInRect(c, CGRectMake(p.x - size / 2, p.y - size / 2, size, size));
    }
}

@end
