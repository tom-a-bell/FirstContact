//
//  OAuthLoginWindowController.h
//  First Contact
//
//  Created by Tom Bell on 17/09/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OATokenManager.h"
#import "OAMutableURLRequest.h"

@interface OAuthLoginWindowController : NSWindowController
{
    OAToken *requestToken;
    OAToken *accessToken;
    OAConsumer *consumer;

    NSDictionary *profile;

    // Theses ivars could be made into a provider class
    // Then you could pass in different providers for Twitter, LinkedIn, etc.
    NSString *apikey;
    NSString *secretkey;
    NSString *requestTokenURLString;
    NSString *accessTokenURLString;
    NSString *userLoginURLString;
    NSString *callbackURL;
    NSURL *requestTokenURL;
    NSURL *accessTokenURL;
    NSURL *userLoginURL;
}

@property (weak) IBOutlet WebView *webView;

@property(nonatomic, retain) OAToken *requestToken;
@property(nonatomic, retain) OAToken *accessToken;
@property(nonatomic, retain) OAConsumer *consumer;

@property(nonatomic, retain) NSDictionary *profile;

- (void)initLinkedInApi;
- (void)requestTokenFromProvider;
- (void)allowUserToLogin;
- (void)accessTokenFromProvider;

@end
