//
//  ViewController.m
//  Drawbridge
//
//  Created by Francis Tseng on 12/12/12.
//  Copyright (c) 2012 Supermedes. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    screenRect = [[UIScreen mainScreen] applicationFrame];
    drawView = [[DrawView alloc] initWithFrame:CGRectMake(screenRect.origin.x
                                                          , screenRect.origin.y - 20
                                                          , screenRect.size.width
                                                          , screenRect.size.height + 20)];
    
    [drawView.menuView.saveButton addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:drawView];
    
    // Success message
    successView = [[UIView alloc] initWithFrame:CGRectMake(screenRect.size.width/2 - 100
                                                           , -200
                                                           , 200
                                                           , 200 )];
    successView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:1.0 alpha:1.0];
    
    // This layer stuff requires #import <QuartzCore/QuartzCore.h>
    successView.layer.cornerRadius = 8;
    successView.layer.masksToBounds = YES;
    successView.layer.borderColor = [UIColor colorWithRed:36.0/255.0 green:134.0/255.0 blue:233.0/255.0 alpha:1.0].CGColor;
    successView.layer.borderWidth = 10.0f;
    
    successImage = [UIImage imageNamed:@"happiness.png"];
    syncingImage = [UIImage imageNamed:@"sync.png"];
    successImageView = [[UIImageView alloc] initWithImage:syncingImage];
    successImageView.center = CGPointMake(successView.frame.size.width/2
                                          , successView.frame.size.height/2 - successImage.size.height/2 + 5);
    successLabel = [[UILabel alloc] initWithFrame:CGRectMake(0
                                                                      , successImageView.frame.origin.y + successImageView.frame.size.height + 20
                                                                      , successView.frame.size.width
                                                                      , 60 )];
    successLabel.textAlignment = UITextAlignmentCenter;
    successLabel.text = @"syncing...";
    successLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    successLabel.textColor = [UIColor whiteColor];
    successLabel.font = [UIFont fontWithName:@"Screen Logger Cool OT" size:36];
    [successView addSubview:successImageView];
    [successView addSubview:successLabel];
    [self.view addSubview:successView];
    
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Double tap
- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint touchLocation = [sender locationInView:nil];
        
        // Top-left
        if ( [drawView isTopLeft:touchLocation] ) {
            [drawView clearDrawing];
            
        // Top-right
        } else if ( [drawView isTopRight:touchLocation] ) {
            [drawView undoDrawing];
            
        // Bottom-left
        } else if ( [drawView isBottomLeft:touchLocation] ) {
            [drawView redoDrawing];
            
        // Bottom-right
        } else if ( [drawView isBottomRight:touchLocation] ) {
        } else {
            [self toggleMenu];
        }
    }
}


-(void) toggleMenu
{
    if ( self.interfaceOrientation == UIInterfaceOrientationPortrait ) {
        if ( drawView.menuView.isShowing ) {
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 [drawView.menuView setCenter:CGPointMake( screenRect.size.width/2
                                                    , screenRect.size.height + drawView.menuView.frame.size.height/2 + 20 )];
                             }];
            drawView.menuView.isShowing = NO;
        } else {
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 [drawView.menuView setCenter:CGPointMake( screenRect.size.width/2
                                                    , drawView.menuView.frame.origin.y - drawView.menuView.frame.size.height/2 )];
                             }];
            drawView.menuView.isShowing = YES;
        }
    } else {
        if ( drawView.menuView.isShowing ) {
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 [drawView.menuView setCenter:CGPointMake( -drawView.menuView.frame.size.width/2
                                                                          , drawView.menuView.frame.size.height/2 )];
                             }];
            drawView.menuView.isShowing = NO;
        } else {
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 [drawView.menuView setCenter:CGPointMake( drawView.menuView.frame.size.width/2
                                                                          , drawView.menuView.frame.size.height/2 )];
                             }];
            drawView.menuView.isShowing = YES;
        }
    }
}

-(void) saveImage:(id)sender {
    if ( session.isAuthenticated ) {
        NSString *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/temp.png"];
        [UIImagePNGRepresentation(drawView.drawing) writeToFile:pngPath atomically:YES];
        [self createPhotoNoteWithPath:pngPath];
    } else {
        [self authenticateEvernoteSession];
//        [self saveImage:nil];
    }
}

-(void)authenticateEvernoteSession {
    session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Could not authenticate"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
        } else {
            NSLog(@"authenticated!");
            [self saveImage:nil];
        }
    }];
}

- (void)createPhotoNoteWithPath:(NSString*)filePath {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [successView setCenter:CGPointMake( screenRect.size.width/2
                                                            , screenRect.size.height/2 - 100 )];
                     }];
    NSData *myFileData = [NSData dataWithContentsOfFile:filePath];
    NSData *dataHash = [myFileData md5];
    EDAMData *edamData = [[EDAMData alloc] initWithBodyHash:dataHash size:myFileData.length body:myFileData];
    EDAMResource* resource = [[EDAMResource alloc] initWithGuid:nil noteGuid:nil data:edamData mime:@"image/png" width:0 height:0 duration:0 active:0 recognition:0 attributes:nil updateSequenceNum:0 alternateData:nil];
    NSString *noteContent = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                             "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
                             "<en-note>"
                             "<br />"
                             "<br />"
                             "%@"
                             "<br />"
                             "<br />"
                             "</en-note>",[ENMLUtility mediaTagWithDataHash:dataHash mime:@"image/png"]];
    EDAMNote *newNote = [[EDAMNote alloc] initWithGuid:nil title:@"Note from Drawbridge" content:noteContent contentHash:nil contentLength:noteContent.length created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:nil tagGuids:nil resources:@[resource] attributes:nil tagNames:nil];
    [[EvernoteNoteStore noteStore] createNote:newNote success:^(EDAMNote *note) {
        NSLog(@"Note created successfully.");
        successLabel.text = @"success!";
        successImageView.image = successImage;
        [self performSelector:@selector(retractSuccessView:) withObject:nil afterDelay:1.5];
        
    } failure:^(NSError *error) {
        NSLog(@"Error creating note : %@",error);
    }];
}

-(void)retractSuccessView:(id)sender {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [successView setCenter:CGPointMake( screenRect.size.width/2
                                                            , -100 )];
                     }
                     completion:^(BOOL finished) {
                         successLabel.text = @"loading...";
                         successImageView.image = syncingImage;
                     }];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Landscape
    if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight )
    {
        // Rotate the main view (sub views are relative to the main view's coordinate system)
        CGAffineTransform transform = self.view.transform;
        
        // Use the status bar frame to determine the center point of the window's content area.
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGRect bounds = CGRectMake(0, 0, statusBarFrame.size.height, statusBarFrame.origin.x);
        CGPoint center = CGPointMake(60.0, bounds.size.height / 2.0);
        
        // Set the center point of the view to the center point of the window's content area.
        self.view.center = center;
        
        // Rotate the view 90 degrees around its new center point.
        transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
        self.view.transform = transform;
        
        // Reposition drawView
//        drawView.frame = CGRectMake(0, 0, self.view.frame.size.width + 20, self.view.frame.size.height);
        [drawView setToLandscape];
        
        // Rotate cachedImage
//        drawView.cachedImage = [[UIImage alloc] initWithCGImage:drawView.cachedImage.CGImage scale:1.0 orientation:UIImageOrientationLeft];
        
        // Reposition drawingColorView and it's subviews
        [drawView.drawingColorView setToLandscape];
//        drawView.drawingColorView.frame = CGRectMake(0, 0, self.view.frame.size.width + 20, self.view.frame.size.height);
//        drawView.drawingColorView.closeButton.frame = CGRectMake(self.view.frame.size.width - 50, -10, 80, 80);
//        drawView.drawingColorView.colorWheel.frame = CGRectMake(drawView.drawingColorView.colorWheel.frame.origin.x
//                                                                , 5
//                                                                , drawView.drawingColorView.colorWheel.frame.size.width
//                                                                , drawView.drawingColorView.colorWheel.frame.size.height);
//        drawView.drawingColorView.wellView.frame = CGRectMake(self.view.frame.size.width - 100
//                                                              , self.view.frame.size.height/2 - drawView.drawingColorView.wellView.frame.size.height
//                                                              , drawView.drawingColorView.wellView.frame.size.width
//                                                              , drawView.drawingColorView.wellView.frame.size.height);
//        drawView.drawingColorView.brightnessSlider.frame = CGRectMake(self.view.frame.size.width - 160
//                                                                      , self.view.frame.size.height/2 + drawView.drawingColorView.wellView.frame.size.height
//                                                                      , 160
//                                                                      , drawView.drawingColorView.brightnessSlider.frame.size.height);
        
        
        // Reposition menu
        if ( drawView.menuView.isShowing ) {
            drawView.menuView.frame = CGRectMake(0, 0
                                                 , 100
                                                 , self.view.frame.size.height);
        } else {
            drawView.menuView.frame = CGRectMake(-100
                                                 , 0
                                                 , 100
                                                 , self.view.frame.size.height);
        }
        
        // Reposition save button
        drawView.menuView.saveButton.frame = CGRectMake(20
                                                        , drawView.menuView.frame.size.height - drawView.menuView.saveButton.frame.size.height - 30
                                                        , drawView.menuView.saveButton.frame.size.width
                                                        , drawView.menuView.saveButton.frame.size.height );
        
    // Portrait
    } else
    {
        
        [drawView setToPortrait];
        [drawView.drawingColorView setToPortrait];
        [drawView.menuView setToPortrait];
        
    }
    NSLog(@"rotated");
    NSLog(@"origin: %f, %f", self.view.frame.origin.x, self.view.frame.origin.y);
    NSLog(@"size: %f, %f", self.view.frame.size.width, self.view.frame.size.height);
    
}



@end
