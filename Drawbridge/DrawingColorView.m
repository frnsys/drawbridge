//
//  DrawingColorView.m
//  Drawbridge
//
//  Created by Francis Tseng on 12/13/12.
//  Copyright (c) 2012 Supermedes. All rights reserved.
//

#import "DrawingColorView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DrawingColorView

@synthesize colorWheel;
@synthesize wellView;
@synthesize brightnessSlider;
@synthesize closeButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:32.0/255.0 alpha:1.0];
        
        // Color wheel
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize size = screenRect.size;
        CGSize wheelSize = CGSizeMake(size.width * .9, size.width * .9);
        
        colorWheel = [[ISColorWheel alloc] initWithFrame:CGRectMake(size.width / 2 - wheelSize.width / 2,
                                                                     size.height * .1,
                                                                     wheelSize.width,
                                                                     wheelSize.height)];
        colorWheel.continuous = true;
        [self addSubview:colorWheel];
        
        brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(size.width * .4,
                                                                       size.height * .8,
                                                                       size.width * .5,
                                                                       size.height * .1)];
        brightnessSlider.minimumValue = 0.0;
        brightnessSlider.maximumValue = 1.0;
        brightnessSlider.value = 1.0;
        [brightnessSlider addTarget:self action:@selector(changeBrightness:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:brightnessSlider];
        
        wellView = [[UIView alloc] initWithFrame:CGRectMake(size.width * .1,
                                                             size.height * .8,
                                                             size.width * .2,
                                                             size.height * .1)];
        
        wellView.layer.borderColor = [UIColor blackColor].CGColor;
        wellView.layer.borderWidth = 1.0;
        [self addSubview:wellView];
        
        // Close button
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width - 80, 0, 80, 80)];
        UIImage* btnImage = [UIImage imageNamed:@"close.png"];
        [closeButton setImage:btnImage forState:UIControlStateNormal];
        frame = closeButton.frame;
        frame.size.width += 26;
        frame.size.height += 20;
        closeButton.frame = frame;
        [closeButton addTarget:self action:@selector(hideSelf:) forControlEvents:UIControlEventTouchUpInside];
        //        closeButton.center = CGPointMake(screenWidth/2, neighborhoodName.center.y + 60);
        [self addSubview:closeButton];
        
        portraitFrame = self.frame;
        colorWheelPortraitFrame = colorWheel.frame;
        wellViewPotraitFrame = wellView.frame;
        brightnessSliderPortraitFrame = brightnessSlider.frame;
        closeButtonPortraitFrame = closeButton.frame;
        
    }
    return self;
}

- (void)changeBrightness:(UISlider*)sender
{
    [colorWheel setBrightness:brightnessSlider.value];
    [colorWheel updateImage];
    [wellView setBackgroundColor:colorWheel.currentColor];
}

-(void)hideSelf:(UISlider*)sender {
    self.hidden = YES;
}

-(void)setToPortrait {
    self.frame = portraitFrame;
    colorWheel.frame = colorWheelPortraitFrame;
    wellView.frame = wellViewPotraitFrame;
    brightnessSlider.frame = brightnessSliderPortraitFrame;
    closeButton.frame = closeButtonPortraitFrame;
}
-(void)setToLandscape {
    self.frame = CGRectMake(0, 0, self.frame.size.height + 20, self.frame.size.width);
    closeButton.frame = CGRectMake(self.frame.size.width - 100, -10, 80, 80);
    colorWheel.frame = CGRectMake(colorWheel.frame.origin.x
                                , 5
                                , colorWheel.frame.size.width
                                , colorWheel.frame.size.height);
    wellView.frame = CGRectMake(self.frame.size.width - 140
                              , self.frame.size.height/2 - wellView.frame.size.height
                              , wellView.frame.size.width
                              , wellView.frame.size.height);
    brightnessSlider.frame = CGRectMake(self.frame.size.width - 200
                                      , self.frame.size.height/2 + wellView.frame.size.height
                                      , 160
                                      , brightnessSlider.frame.size.height);
}


@end
