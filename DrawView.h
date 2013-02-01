//
//  DrawView.h
//  Drawbridge
//
//  Created by Francis Tseng on 12/12/12.
//  Copyright (c) 2012 Supermedes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuView.h"
#import "DrawingColorView.h"
#import "ISColorWheel.h"

@interface DrawView : UIView <ISColorWheelDelegate> {
    
    UIBezierPath *path;
    
    // Keep track of history for undo
    NSMutableArray *undoStack;
    NSMutableArray *redoStack;
    
    // instead of saving cached images to history i should be saving path info (probably takes less space than cached images). that way i can remove paths one by one and then redraw cached images accordingly.
    
    // Keep track of bezier points + the control point of the next segment
    CGPoint points[5];
    
    // Keep track of point index
    uint counter;
    
    // Keep track of if drawing is happening.
    // This allows us to detect a tap, so we can just draw a point.
//    BOOL isDrawing;
    
    // The range we look for corner taps
    float tapRange;
    
    // Keep track of stroke color
    UIColor* strokeColor;
    
    
    // Keep track of when an undo operation is occuring,
    // so we don't add the undo path back to the undo stack.
    BOOL isUndoing;
    
    CGRect portraitFrame;
}

@property CGRect screenRect;
@property (nonatomic, retain) MenuView *menuView;
@property (nonatomic, retain) UIImage *drawing;
@property (nonatomic, retain) DrawingColorView* drawingColorView;

// Save what we've drawn so far
@property (nonatomic, retain) UIImage *cachedImage;

-(void) clearDrawing;
-(void) undoDrawing;
-(void) redoDrawing;

-(BOOL)isTopLeft:(CGPoint)point;
-(BOOL)isTopRight:(CGPoint)point;
-(BOOL)isBottomLeft:(CGPoint)point;
-(BOOL)isBottomRight:(CGPoint)point;

-(void)setToPortrait;
-(void)setToLandscape;

@end
