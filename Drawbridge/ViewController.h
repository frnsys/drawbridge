//
//  ViewController.h
//  Drawbridge
//
//  Created by Francis Tseng on 12/12/12.
//  Copyright (c) 2012 Supermedes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawView.h"
#import "EvernoteSDK.h"
#import "NSData+EvernoteSDK.h"
#import "ENMLUtility.h"

@interface ViewController : UIViewController {
    DrawView* drawView;
    UIView* successView;
    CGRect screenRect;
    EvernoteSession *session;
    UIImage* successImage;
    UIImage* syncingImage;;
    UIImageView* successImageView;
    UILabel* successLabel;
}


@end
