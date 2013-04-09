//
//  TSTouchView.h
//  TouchSize
//
//  Created by Danis Tazetdinov on 08.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TSTouchViewDelegate;

@interface TSTouchView : UIView

@property (weak, nonatomic) id<TSTouchViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIImage *currentDrawing;

-(void)clearDrawing;

@end

@protocol TSTouchViewDelegate <NSObject>

-(void)touchView:(TSTouchView*)sender startedTouchWithSize:(float)touchSize;
-(void)touchView:(TSTouchView*)sender movedTouchWithSize:(float)touchSize;
-(void)touchViewEndedTouch:(TSTouchView*)sender;

@end
