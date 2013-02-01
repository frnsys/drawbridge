//
//  MenuView.m
//  Drawbridge
//
//  Created by Francis Tseng on 12/13/12.
//  Copyright (c) 2012 Supermedes. All rights reserved.
//

#import "MenuView.h"

@implementation MenuView

@synthesize colorButton;
@synthesize saveButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:1.0 alpha:1.0]];
        
        UIView* menuA = [[UIView alloc] initWithFrame:CGRectMake(0, 0
                                                                 , self.frame.size.width
                                                                 , self.frame.size.height )];
        [self addSubview:menuA];
        
        /*
        UIView* menuB = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width
                                                                 , 0
                                                                 , self.frame.size.width
                                                                 , self.frame.size.height )];
        [self addSubview:menuB];
        
        self.contentSize = CGSizeMake( self.frame.size.width * 2, self.frame.size.height );
        self.pagingEnabled = YES;
         */
        
        colorButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.frame.size.height/2 - 40, 60, 60)];
        UIImage* colorImage = [UIImage imageNamed:@"color.png"];
        [colorButton setImage:colorImage forState:UIControlStateNormal];
        [menuA addSubview:colorButton];
        
        saveButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, self.frame.size.height/2 - 40, 60, 60)];
        UIImage* saveImage = [UIImage imageNamed:@"save.png"];
        [saveButton setImage:saveImage forState:UIControlStateNormal];
        [menuA addSubview:saveButton];
        
        portraitFrame = self.frame;
        saveButtonPortraitFrame = saveButton.frame;
    }
    return self;
}

-(void)setToPortrait {
    self.frame = portraitFrame;
    saveButton.frame = saveButtonPortraitFrame;
}
-(void)setToLandscape {
}

@end

