//
//  DrawView.m
//  Drawbridge
//
//  Created by Francis Tseng on 12/12/12.
//  Copyright (c) 2012 Supermedes. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

@synthesize menuView;
@synthesize drawing;
@synthesize screenRect;
@synthesize drawingColorView;
@synthesize cachedImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        screenRect = [[UIScreen mainScreen] applicationFrame];
        tapRange = 50.0;
        
        portraitFrame = self.frame;
        
        // Add the menu
        menuView = [[MenuView alloc] initWithFrame:CGRectMake(screenRect.origin.x
                                                              , screenRect.size.height + 20
                                                              , screenRect.size.width
                                                              , 100)];
        [menuView.colorButton addTarget:self action:@selector(toggleDrawingColorView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:menuView];
        
        drawingColorView = [[DrawingColorView alloc] initWithFrame:CGRectMake(0, -20
                                                                              , screenRect.size.width
                                                                              , screenRect.size.height + 20 )];
        drawingColorView.colorWheel.delegate = self;
        drawingColorView.hidden = YES;
        [self addSubview:drawingColorView];
        
        // Disable multiple touches
        [self setMultipleTouchEnabled:NO];
        
        // Set background color
        [self setBackgroundColor:[UIColor whiteColor]];
        
        // Init path history
        undoStack = [[NSMutableArray alloc] init];
        redoStack = [[NSMutableArray alloc] init];
        
        // Init our path
        path = [UIBezierPath bezierPath];
        
        // Set stroke width
        [path setLineWidth:2.0];
        
        // Set default stroke color
        strokeColor = [UIColor blackColor];
        

    }
    return self;
}

// drawRect is called automatically by [self setNeedsDisplay] down below
- (void)drawRect:(CGRect)rect
{
    // Draw the cached image to screen
    [cachedImage drawInRect:rect];
    
    // Set stroke color
    [strokeColor setStroke];
    [path setLineWidth:2.0];
    
    // Draw the path
    [path stroke];
}

// Start of touch, start of a new bezier curve
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    counter = 0;
    UITouch *touch = [touches anyObject];
    points[0] = [touch locationInView:self];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Drawing resuming means clearing the redo stack
    // Can't put this in touchesBegan because
    // the first tap of a double tap registers as a touch beginning
    [redoStack removeAllObjects];
    
//    isDrawing = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    counter++;
    points[counter] = p;
    if (counter == 4)
    {
        // Move the endpoint to the middle of the line
        // joining the second control point of the first Bezier segment
        // and the first control point of the second Bezier segment
        points[3] = CGPointMake((points[2].x + points[4].x)/2.0, (points[2].y + points[4].y)/2.0);
        [path moveToPoint:points[0]];
        
        // Add a cubic Bezier from pt[0] to pt[3],
        // with control points pt[1] and pt[2]
        [path addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]];
        [self setNeedsDisplay];
        
        // Replace points and
        // get ready to handle the next segment
        points[0] = points[3];
        points[1] = points[4];
        counter = 1;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // Draw a dot if a stroke isn't being made
    /*
    if ( !isDrawing ) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        // Don't draw points if triggering redo
        if ( ![self isBottomLeft:point] && ![self isTopLeft:point] && ![self isTopRight:point] ) {
            CGRect frame = CGRectMake(point.x, point.y, 2, 2);
            path = [UIBezierPath bezierPathWithOvalInRect:frame];
        }
    }
    */ 
    
    // Add the path to the undoStack
//    NSLog(@"touches ended called");
    if ( !isUndoing && !path.isEmpty ) {
        UIBezierPath *historyPath = [path copy];
        [undoStack addObject:historyPath];
    } else {
        isUndoing = NO;
    }
    
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    counter = 0;
    
//    isDrawing = NO;
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}
- (void)drawBitmap
{
    // Create the canvas/context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    
    // If there's no cached image (i.e. this is the first time drawing),
    // set white background
    if (!cachedImage)
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }
    
    // Draw the existing cached image
    [cachedImage drawAtPoint:CGPointZero];
    
    // Draw the new path
    [strokeColor setStroke];
    [path setLineWidth:2.0];
    [path stroke];
    
    // Get a new snapshot for the cached image
    cachedImage = UIGraphicsGetImageFromCurrentImageContext();
    drawing = UIGraphicsGetImageFromCurrentImageContext();
    
    // Fin.
    UIGraphicsEndImageContext();
    
}

- (void) clearDrawing
{
    cachedImage = nil;
    [self setNeedsDisplay];
    
}

-(void) undoDrawing
{
//    NSLog(@"undo called, stack size: %i", [undoStack count]);
    isUndoing = YES;
    
    // Only "undo" if there are undo items
    if ( [undoStack count] > 0 )
    {
        // Clear the canvas
        [self clearDrawing];
        
        // Add the latest path to the redoStack
        [redoStack addObject:[undoStack lastObject]];
        
        // Remove the latest path from the undoStack
        [undoStack removeLastObject];
        
        // Create a path out of paths from the undo stack
        UIBezierPath *aggregateHistoryPath = [UIBezierPath bezierPath];
        for (UIBezierPath *historyPath in undoStack) {
            [aggregateHistoryPath appendPath:historyPath];
        }
        
        path = aggregateHistoryPath;
        
        // Redraw the screen
        [self drawBitmap];
        [self setNeedsDisplay];
    }
}

-(void) redoDrawing
{
//    NSLog(@"redo called, stack size: %i", [redoStack count]);
    // Only "redo" if there are redo items
    if ( [redoStack count] > 0 )
    {
        path = [redoStack lastObject];
        [redoStack removeLastObject];
        
        // Add the redo'd path to the undoStack
        UIBezierPath *historyPath = [path copy];
        [undoStack addObject:historyPath];
        
        isUndoing = YES;
        
        // Redraw the screen
        [self drawBitmap];
        [self setNeedsDisplay];
    }
}

-(void)toggleDrawingColorView:(id)sender
{
    if ( drawingColorView.hidden ) {
        drawingColorView.hidden = NO;
    } else {
        drawingColorView.hidden = YES;
    }
}
- (void)colorWheelDidChangeColor:(ISColorWheel *)colorWheel
{
    strokeColor = drawingColorView.colorWheel.currentColor;
    [drawingColorView.wellView setBackgroundColor:drawingColorView.colorWheel.currentColor];
}

-(BOOL)isTopLeft:(CGPoint)point {
    if ( point.x < tapRange && point.y < tapRange ) {
        return YES;
    }
    return NO;
}
-(BOOL)isTopRight:(CGPoint)point {
    if ( point.x > screenRect.size.width - tapRange && point.y < tapRange ) {
        return YES;
    }
    return NO;
}
-(BOOL)isBottomLeft:(CGPoint)point {
    if ( point.x < tapRange && point.y > screenRect.size.height - tapRange ) {
        return YES;
    }
    return NO;
}
-(BOOL)isBottomRight:(CGPoint)point {
    if ( point.x > screenRect.size.width - tapRange && point.y > screenRect.size.height - tapRange ) {
        return YES;
    }
    return NO;
}

-(void)setToPortrait {
    self.frame = portraitFrame;
}
-(void)setToLandscape {
    self.frame = CGRectMake(0, 0, self.frame.size.height + 20, self.frame.size.width);
}

@end
