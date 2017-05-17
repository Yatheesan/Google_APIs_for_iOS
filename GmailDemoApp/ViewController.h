//
//  ViewController.h
//  GmailDemoApp
//
//  Created by Yatheesan Chandreswaran on 4/28/17.
//  Copyright © 2017 Yatheesan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLRGmail.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) GTLRGmailService *service;
@property (nonatomic, strong) UITextView *output;

@end

