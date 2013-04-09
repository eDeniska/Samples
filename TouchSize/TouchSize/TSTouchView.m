//
//  TSTouchView.m
//  TouchSize
//
//  Created by Danis Tazetdinov on 08.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TSTouchView.h"

CGFloat const kTSTouchViewMultiplyFactor = 6.45f;
// value of 6.45f provides actual size in points

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

#pragma mark - Drawing context preparation

-(CGContextRef)prepareContextWithLineWidth:(CGFloat)width
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.currentDrawing drawInRect:self.bounds];
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(c, kCGLineCapRound);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetLineWidth(c, width);
    [self.colors[self.currentColor] setStroke];

    return c;
}

-(void)disposeContext
{
    self.currentDrawing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

#pragma mark - Curved line draw code

-(void)putStartPoint:(CGPoint)point withWidth:(CGFloat)width 
{
    self.currentColor++;
    if (self.currentColor == self.colors.count)
    {
        self.currentColor = 0;
    }

    self.point = point;
    self.middleSet = NO;

    CGContextRef c = [self prepareContextWithLineWidth:width];

    CGContextMoveToPoint(c, self.point.x, self.point.y);
    CGContextAddLineToPoint(c, self.point.x, self.point.y);
    CGContextStrokePath(c);

    [self disposeContext];
}

-(void)moveToPoint:(CGPoint)point withWidth:(CGFloat)width
{
    CGContextRef c = [self prepareContextWithLineWidth:width];

    if (self.middleSet)
    {
        CGContextMoveToPoint(c, self.middle.x, self.middle.y);
        self.middle = CGPointMake((self.point.x + point.x) / 2,
                                  (self.point.y + point.y) / 2);
        CGContextAddQuadCurveToPoint(c, self.point.x, self.point.y, self.middle.x, self.middle.y);
        self.point = point;
    }
    else
    {
        CGContextMoveToPoint(c, self.point.x, self.point.y);
        self.middle = CGPointMake((self.point.x + point.x) / 2,
                                  (self.point.y + point.y) / 2);
        self.point = point;
        CGContextAddLineToPoint(c, self.point.x, self.point.y);
        self.middleSet = YES;
    }
    CGContextStrokePath(c);
    
    [self disposeContext];
}

-(void)finishAtPoint:(CGPoint)point withWidth:(CGFloat)width
{
    CGContextRef c = [self prepareContextWithLineWidth:width];
    
    if (self.middleSet)
    {
        CGContextMoveToPoint(c, self.middle.x, self.middle.y);
    }
    else
    {
        CGContextMoveToPoint(c, self.point.x, self.point.y);
    }
    self.point = point;
    CGContextAddLineToPoint(c, self.point.x, self.point.y);
    CGContextStrokePath(c);
    
    [self disposeContext];
}

#pragma mark - Touch events handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    [self putStartPoint:[touch locationInView:self]
              withWidth:[[touch valueForKey:@"pathMajorRadius"] floatValue] * kTSTouchViewMultiplyFactor];
    
    [self.delegate touchView:self startedTouchWithSize:[[touch valueForKey:@"pathMajorRadius"] floatValue]];
    
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    [self moveToPoint:[touch locationInView:self]
            withWidth:[[touch valueForKey:@"pathMajorRadius"] floatValue] * kTSTouchViewMultiplyFactor];
    
    [self.delegate touchView:self movedTouchWithSize:[[touch valueForKey:@"pathMajorRadius"] floatValue]];
    
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    [self finishAtPoint:[touch locationInView:self]
              withWidth:[[touch valueForKey:@"pathMajorRadius"] floatValue] * kTSTouchViewMultiplyFactor];
    
    [self.delegate touchView:self movedTouchWithSize:[[touch valueForKey:@"pathMajorRadius"] floatValue]];
    [self.delegate touchViewEndedTouch:self];
    
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchViewEndedTouch:self];
}

#pragma mark - Actual draw code

- (void)drawRect:(CGRect)rect
{
    [self.currentDrawing drawInRect:self.bounds];
}

#pragma mark - Clear action

-(void)clearDrawing
{
    self.currentDrawing = nil;
    [self setNeedsDisplay];
}


@end

