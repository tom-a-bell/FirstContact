//
//  ContactEntryCellView.m
//  First Contact
//
//  Created by Tom Bell on 12/09/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ContactEntryCellView.h"

@implementation ContactEntryCellView

@synthesize label = _label;
@synthesize entry = _entry;
@synthesize city = _city;
@synthesize region = _region;
@synthesize postcode = _postcode;
@synthesize country = _country;
@synthesize addButton = _addButton;
@synthesize labelOptions = _labelOptions;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isAddress = NO;
    }
    return self;
}

- (void)layoutViewForAddressMode:(BOOL)addressMode animated:(BOOL)animated
{
    if (_isAddress != addressMode) {
        _isAddress = addressMode;
        [_city setHidden:(!_isAddress)];
        [_region setHidden:(!_isAddress)];
        [_postcode setHidden:(!_isAddress)];
        [_country setHidden:(!_isAddress)];
    }
}

@end
