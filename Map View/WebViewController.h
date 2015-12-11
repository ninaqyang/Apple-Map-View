//
//  WebViewController.h
//  Map View
//
//  Created by Nina Yang on 9/10/15.
//  Copyright (c) 2015 Nina Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) NSURL *url;

@end
