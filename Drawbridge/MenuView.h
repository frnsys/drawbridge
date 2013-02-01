//
//  MenuView.h
//  Drawbridge
//
//  Created by Francis Tseng on 12/13/12.
//  Copyright (c) 2012 Supermedes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuView : UIScrollView {
    CGRect portraitFrame;
    CGRect saveButtonPortraitFrame;
}

@property BOOL isShowing;

@property (nonatomic, retain) UIButton *colorButton;
@property (nonatomic, retain) UIButton *saveButton;

-(void)setToPortrait;
-(void)setToLandscape;

@end
