//
//  OAuthLoginWindowController.h
//  First Contact
//
//  Created by Tom Bell on 17/09/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface OAuthLoginWindowController : NSWindowController

@property (weak) IBOutlet WebView *webView;

@end
