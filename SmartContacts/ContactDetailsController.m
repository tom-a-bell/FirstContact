//
//  ContactDetails.m
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ContactDetailsController.h"

@implementation ContactDetailsController

+ (ContactDetailsController *)contactDetailsController {
    static ContactDetailsController *gContactDetailsController = nil;
    if (gContactDetailsController == nil) {
        gContactDetailsController = [[[self class] alloc] initWithNibName:@"ContactDetails"
                                                                   bundle:[NSBundle
                                                                           bundleForClass:[self class]]];
    }
    return gContactDetailsController;
}

@synthesize delegate;

- (void)loadView {
    [super loadView];
}

- (void)_makePopoverIfNeeded {
    if (_popover == nil) {
        // Create and setup our window
        _popover = [[NSPopover alloc] init];
        // The popover retains us and we retain the popover. We drop the popover whenever it is closed to avoid a cycle.
        _popover.contentViewController = self;
        _popover.behavior = NSPopoverBehaviorTransient;
        _popover.delegate = self;
    }
}

- (void)updatePopover:(NSDictionary *)contact withPositioningView:(NSView *)positioningView
{
    [self.name  setStringValue:[contact valueForKey:@"Name"]];
    [self.email setStringValue:[contact valueForKey:@"Email"]];
    [self.phone setStringValue:[contact valueForKey:@"Phone"]];
    [self.addr  setStringValue:[contact valueForKey:@"Address"]];
    [self.bday  setObjectValue:[contact valueForKey:@"Birthday"]];
    [self _makePopoverIfNeeded];
    [_popover showRelativeToRect:[positioningView bounds] ofView:positioningView preferredEdge:NSMinYEdge];
}

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover
{
//    [self.popoverWindow setContentView:self.popoverView];
    return self.popoverWindow;
}

- (void)popoverDidClose:(NSNotification *)notification {
    // Free the popover to avoid a cycle. We could also just break the contentViewController property, and reset it when we show the popover
    _popover = nil;
    self.popoverWindow = nil;
}

@end
