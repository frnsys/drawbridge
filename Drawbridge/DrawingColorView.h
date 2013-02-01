//
//  DrawingColorView.h
//  Drawbridge
//
//  Created by Francis Tseng on 12/13/12.
//  Copyright (c) 2012 Supermedes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISColorWheel.h"

@interface DrawingColorView : UIView {
    CGRect portraitFrame;
    CGRect colorWheelPortraitFrame;
    CGRect wellViewPotraitFrame;
    CGRect brightnessSliderPortraitFrame;
    CGRect closeButtonPortraitFrame;
}

@property (nonatomic, retain) ISColorWheel* colorWheel;
@property (nonatomic, retain) UIView* wellView;
@property (nonatomic, retain) UISlider* brightnessSlider;
@property (nonatomic, retain) UIButton* closeButton;

-(void)setToPortrait;
-(void)setToLandscape;

@end
