//
//  OAuthLoginWindowController.m
//  First Contact
//
//  Created by Tom Bell on 17/09/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "OAuthLoginWindowController.h"

#import <Foundation/NSNotificationQueue.h>
#import <WebKit/WebKit.h>

#import "OAConsumer.h"

//
//  iPhone OAuth Starter Kit
//
//  Supported providers: LinkedIn (OAuth 1.0a)
//
//  Lee Whitney
//  http://whitneyland.com
//
//
//  OAuth steps for version 1.0a:
//
//  1. Request a "request token"
//  2. Show the user a browser with the LinkedIn login page
//  3. LinkedIn redirects the browser to our callback URL
//  4  Request an "access token"
//

#define API_KEY_LENGTH 12
#define SECRET_KEY_LENGTH 16

@implementation OAuthLoginWindowController

@synthesize webView = _webView;

@synthesize requestToken, accessToken, consumer, profile;

//
// OAuth step 1a:
//
// The first step in the OAuth process is to make a request for a "request token".
// Yes, it's confusing that the word request is mentioned twice, but that's what's happening.
//
- (void)requestTokenFromProvider
{
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc]
                                    initWithURL:requestTokenURL
                                       consumer:self.consumer
                                          token:nil
                                       callback:callbackURL
                              signatureProvider:nil];

    [request setHTTPMethod:@"POST"];

    OARequestParameter *nameParam = [[OARequestParameter alloc] initWithName:@"scope"
                                                                       value:@"r_basicprofile+rw_nus"];
    NSArray *params = [NSArray arrayWithObjects:nameParam, nil];
    [request setParameters:params];
    OARequestParameter * scopeParameter=[OARequestParameter requestParameter:@"scope" value:@"r_fullprofile rw_nus"];

    [request setParameters:[NSArray arrayWithObject:scopeParameter]];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenResult:didFinish:)
                  didFailSelector:@selector(requestTokenResult:didFail:)];
}

//
// OAuth step 1b:
//
// When this method is called it means we have successfully received a request token.
// We then show a WebView that sends the user to the LinkedIn login page.
// The request token is added as a parameter to the url of the login page.
// LinkedIn reads the token on their end to know which app the user is granting access to.
//
- (void)requestTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    if (!ticket.didSucceed) return;

    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    self.requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    [self allowUserToLogin];
}

- (void)requestTokenResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

//
// OAuth step 2:
//
// Show the user a browser displaying the LinkedIn login page.
// They enter their username/password and this is how they permit us to access their data
// We use a WebView for this.
//
// Sending the token information is required, but in this one case OAuth requires us
// to send URL query parameters instead of putting the token in the HTTP Authorization
// header as we do in all other cases.
//
- (void)allowUserToLogin
{
    NSString *userLoginURLWithToken = [NSString stringWithFormat:@"%@?oauth_token=%@",
                                       userLoginURLString, self.requestToken.key];

    userLoginURL = [NSURL URLWithString:userLoginURLWithToken];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL: userLoginURL];
    [[_webView mainFrame] loadRequest:request];
}


//
// OAuth step 3:
//
// This method is called when our WebView browser loads a URL, this happens 3 times:
//
//      a) Our own [[_webView mainFrame] loadRequest] message sends the user to the LinkedIn login page.
//
//      b) The user types in their username/password and presses 'OK', this will submit
//         their credentials to LinkedIn
//
//      c) LinkedIn responds to the submit request by redirecting the browser to our callback URL
//         If the user approves they also add two parameters to the callback URL: oauth_token and oauth_verifier.
//         If the user does not allow access the parameter user_refused is returned.
//
//      Example URLs for these three load events:
//          a) https://www.linkedin.com/uas/oauth/authorize?oauth_token=<token value>
//
//          b) https://www.linkedin.com/uas/oauth/authorize/submit   OR
//             https://www.linkedin.com/uas/oauth/authenticate?oauth_token=<token value>&trk=uas-continue
//
//          c) hdlinked://linkedin/oauth?oauth_token=<token value>&oauth_verifier=63600     OR
//             hdlinked://linkedin/oauth?user_refused
//
//
//  We only need to handle case (c) to extract the oauth_verifier value
//

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;

//    addressBar.text = urlString;
//    [activityIndicator startAnimating];

    BOOL requestForCallbackURL = ([urlString rangeOfString:callbackURL].location != NSNotFound);
    if (requestForCallbackURL)
    {
        BOOL userAllowedAccess = ([urlString rangeOfString:@"user_refused"].location == NSNotFound);
        if (userAllowedAccess)
        {
            [self.requestToken setVerifierWithUrl:url];
            [self accessTokenFromProvider];
        }
        else
        {
            // User refused to allow our app access
            // Notify parent and close this window
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"loginWindowDidFinish"
             object:self
             userInfo:nil];

            [self close];
        }
    }
    else
    {
        // Case (a) or (b), so ignore it
    }
	[listener use];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
//    [activityIndicator stopAnimating];
}

//
// OAuth step 4:
//
- (void)accessTokenFromProvider
{
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc]
                                    initWithURL:accessTokenURL
                                       consumer:self.consumer
                                          token:self.requestToken
                                       callback:nil
                              signatureProvider:nil];

    [request setHTTPMethod:@"POST"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenResult:didFinish:)
                  didFailSelector:@selector(accessTokenResult:didFail:)];
}

- (void)accessTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];

    BOOL problem = ([responseBody rangeOfString:@"oauth_problem"].location != NSNotFound);
    if (problem)
    {
        NSLog(@"Request access token failed.");
        NSLog(@"%@",responseBody);
    }
    else
    {
        self.accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    }

    // Notify parent and close this window
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"loginWindowDidFinish"
     object:self];

    [self close];
}

//
//  This API consumer data could move to a provider object
//  to allow easy switching between LinkedIn, Twitter, etc.
//
- (void)initLinkedInApi
{
    apikey = @"jrk6ry3gb72i";
    secretkey = @"lUggmZ3bX9KjfA6T";

    self.consumer = [[OAConsumer alloc] initWithKey:apikey
                                             secret:secretkey
                                              realm:@"http://api.linkedin.com/"];

    requestTokenURLString = @"https://api.linkedin.com/uas/oauth/requestToken";
    accessTokenURLString  = @"https://api.linkedin.com/uas/oauth/accessToken";
    userLoginURLString    = @"https://www.linkedin.com/uas/oauth/authorize";
    callbackURL           = @"hdlinked://linkedin/oauth";

    requestTokenURL = [NSURL URLWithString:requestTokenURLString];
    accessTokenURL = [NSURL URLWithString:accessTokenURLString];
    userLoginURL = [NSURL URLWithString:userLoginURLString];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self initLinkedInApi];
    if ([apikey length] < API_KEY_LENGTH || [secretkey length] < SECRET_KEY_LENGTH)
    {
        NSLog(@"OAuth error: you must add your apikey and secretkey.");

        // Notify parent and close this window
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"loginWindowDidFinish"
         object:self];

        [self close];
    }

    [_webView setShouldCloseWithWindow:YES];
    [_webView setFrameLoadDelegate:self];
    [_webView setPolicyDelegate:self];

    [self requestTokenFromProvider];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

@end
