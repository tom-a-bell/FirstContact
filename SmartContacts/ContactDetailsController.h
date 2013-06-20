//
//  ContactDetails.h
//  SmartContacts
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ContactDetailsControllerDelegate;

@interface ContactDetailsController : NSViewController <NSPopoverDelegate> {
@private
    id <ContactDetailsControllerDelegate> _delegate;
    NSPopover *_popover;
}

@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *email;
@property (weak) IBOutlet NSTextField *phone;
@property (weak) IBOutlet NSTextField *addr;
@property (weak) IBOutlet NSTextField *bday;
@property (strong) IBOutlet NSWindow *popoverWindow;
@property (weak) IBOutlet NSView *popoverView;

@property(assign) id <ContactDetailsControllerDelegate> delegate;

+ (ContactDetailsController *)contactDetailsController;

- (void)updatePopover:(NSDictionary *)contact withPositioningView:(NSView *)positioningView;

@end

@protocol ContactDetailsControllerDelegate <NSObject>

@optional
- (void)contactDetailsController:(ContactDetailsController *)controller;
@end
