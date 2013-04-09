//
//  TSTouchView.m
//  TouchSize
//
//  Created by Danis Tazetdinov on 08.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TSTouchView.h"

CGFloat const kTSTouchViewMultiplyFactor = 1.5f;

@interface TSTouchView()

@property (nonatomic, strong, readwrite) UIImage *currentDrawing;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGPoint middle;
@property (nonatomic, assign) BOOL middleSet;

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, assign) int currentColor;

-(void)configure;

@end

@implementation TSTouchView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configure];
    }
    
    return self;
}

-(void)awakeFromNib
{
    [self configure];
}

-(void)configure
{
    self.colors = @[ [UIColor redColor], [UIColor orangeColor], [UIColor greenColor],
                     [UIColor yellowColor], [UIColor blueColor],
                     [UIColor whiteColor], [UIColor blackColor] ];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.currentColor++;
    if (self.currentColor == self.colors.count)
    {
        self.currentColor = 0;
    }
    
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [self.currentDrawing drawInRect:self.bounds];

    UITouch *touch = [touches anyObject];
    self.point = [touch locationInView:self];
    self.middleSet = NO;

    CGContextSetLineCap(c, kCGLineCapRound);
    CGContextSetLineJoin(c, kCGLineJoinRound);

    CGContextSetLineWidth(c, [[touch valueForKey:@"pathMajorRadius"] floatValue] * kTSTouchViewMultiplyFactor);
    
    CGContextMoveToPoint(c, self.point.x, self.point.y);
    CGContextAddLineToPoint(c, self.point.x, self.point.y);
    [self.colors[self.currentColor] setStroke];
    CGContextStrokePath(c);
    self.currentDrawing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [self.currentDrawing drawInRect:self.bounds];
    [self.colors[self.currentColor] setStroke];
    UITouch *touch = [touches anyObject];
    
    CGContextSetLineCap(c, kCGLineCapRound);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetLineWidth(c, [[touch valueForKey:@"pathMajorRadius"] floatValue] * kTSTouchViewMultiplyFactor);

    if (self.middleSet)
    {
        CGContextMoveToPoint(c, self.middle.x, self.middle.y);
        CGPoint touchPoint = [touch locationInView:self];
        self.middle = CGPointMake((self.point.x + touchPoint.x) / 2,
                                        (self.point.y + touchPoint.y) / 2);
        CGContextAddQuadCurveToPoint(c, self.point.x, self.point.y, self.middle.x, self.middle.y);
        self.point = touchPoint;
    }
    else
    {
        CGContextMoveToPoint(c, self.point.x, self.point.y);
        CGPoint touchPoint = [touch locationInView:self];
        self.middle = CGPointMake((self.point.x + touchPoint.x) / 2,
                                        (self.point.y + touchPoint.y) / 2);
        self.point = touchPoint;
        CGContextAddLineToPoint(c, self.point.x, self.point.y);
        self.middleSet = YES;
    }
    CGContextStrokePath(c);
    
    self.currentDrawing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [self.currentDrawing drawInRect:self.bounds];
    [self.colors[self.currentColor] setStroke];
    UITouch *touch = [touches anyObject];
    
    CGContextSetLineCap(c, kCGLineCapRound);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetLineWidth(c, [[touch valueForKey:@"pathMajorRadius"] floatValue] * kTSTouchViewMultiplyFactor);

    if (self.middleSet)
    {
        CGContextMoveToPoint(c, self.middle.x, self.middle.y);
    }
    else
    {
        CGContextMoveToPoint(c, self.point.x, self.point.y);
    }
    self.point = [touch locationInView:self];
    CGContextAddLineToPoint(c, self.point.x, self.point.y);
    CGContextStrokePath(c);
    
    self.currentDrawing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setNeedsDisplay];
    self.middleSet = NO;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // do nothing
}

- (void)drawRect:(CGRect)rect
{
    [self.currentDrawing drawInRect:self.bounds];
}

-(void)clearDrawing
{
    self.currentDrawing = nil;
    [self setNeedsDisplay];
}


@end

