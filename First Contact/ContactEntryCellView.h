//
//  ContactEntryCellView.h
//  First Contact
//
//  Created by Tom Bell on 12/09/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ContactEntryCellView : NSTableCellView
{
@private
    BOOL _isAddress;
}

@property (assign) IBOutlet NSPopUpButton *label;
@property (assign) IBOutlet NSTextField *entry;
@property (assign) IBOutlet NSTextField *city;
@property (assign) IBOutlet NSTextField *region;
@property (assign) IBOutlet NSTextField *postcode;
@property (assign) IBOutlet NSTextField *country;
@property (assign) IBOutlet NSButton *addButton;
@property (assign) IBOutlet NSMenu *labelOptions;

- (void)layoutViewForAddressMode:(BOOL)addressMode animated:(BOOL)animated;

@end
