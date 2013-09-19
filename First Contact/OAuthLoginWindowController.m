//
//  OAuthLoginWindowController.m
//  First Contact
//
//  Created by Tom Bell on 17/09/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "OAuthLoginWindowController.h"

#import <WebKit/WebKit.h>

@implementation OAuthLoginWindowController

@synthesize webView = _webView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.linkedin.com"]]];
}

@end
