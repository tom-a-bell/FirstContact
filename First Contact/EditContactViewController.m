//
//  EditContactViewController.m
//  First Contact
//
//  Created by Tom Bell on 13/09/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "EditContactViewController.h"
#import "ContactEntryCellView.h"

#import "AppDelegate.h"

#import "Contact.h"
#import "Email.h"
#import "Phone.h"
#import "Address.h"

@interface EditContactViewController ()

@end

@implementation EditContactViewController

@synthesize contact = _contact;
@synthesize delegate = _delegate;
@synthesize needsSaving = _needsSaving;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contact:(Contact*)contactOrNil delegate:(id)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        editMode = (contactOrNil != nil);
        self.needsSaving = NO;
        self.delegate = delegate;
        self.contact = editMode ? contactOrNil : [self.delegate newContact];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    [self setRepresentedObject:self.contact];

    if (self.contact.image) self.portraitImage.image = [[NSImage alloc] initWithData:self.contact.image];
    if (self.contact.firstName) self.firstName.stringValue = self.contact.firstName;
    if (self.contact.lastName) self.lastName.stringValue = self.contact.lastName;
    if (self.contact.relation) self.relation.stringValue = self.contact.relation;
    if (self.contact.company) self.company.stringValue = self.contact.company;
    
    if (!_tableContents)
    {
        _tableContents = [NSMutableArray new];
        [self willChangeValueForKey:@"_tableContents"];
        
        // Create a sort descriptor to sort the entries by label type
        NSSortDescriptor *sortByType = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
        
        NSArray *emailList = [self.contact.hasEmail sortedArrayUsingDescriptors:@[sortByType]];
        if (emailList.count > 0)
        {
            for (Email *email in emailList)
                [_tableContents addObject:email];
        }
        else if (self.contact.email != nil && ![self.contact.email isEqualToString:@""])
        {
            Email *email = [self newEntryOfType:[Email class]];
            email.address = self.contact.email;
            self.contact.email = nil;
            [_tableContents addObject:email];
        }
        else
        {
            Email *email = [self newEntryOfType:[Email class]];
            [_tableContents addObject:email];
        }
        
        NSArray *phoneList = [self.contact.hasPhone sortedArrayUsingDescriptors:@[sortByType]];
        if (phoneList.count > 0)
        {
            for (Phone *phone in phoneList)
                [_tableContents addObject:phone];
        }
        else if (self.contact.phone != nil && ![self.contact.phone isEqualToString:@""])
        {
            Phone *phone = [self newEntryOfType:[Phone class]];
            phone.number = self.contact.phone;
            self.contact.phone = nil;
            [_tableContents addObject:phone];
        }
        else
        {
            Phone *phone = [self newEntryOfType:[Phone class]];
            [_tableContents addObject:phone];
        }
        
        NSArray *addressList = [self.contact.hasAddress sortedArrayUsingDescriptors:@[sortByType]];
        if (addressList.count > 0)
        {
            for (Address *address in addressList)
                [_tableContents addObject:address];
        }
        else if (self.contact.fullAddress != nil && ![self.contact.fullAddress isEqualToString:@""])
        {
            Address *address = [self newEntryOfType:[Address class]];
            address.city = self.contact.city;
            address.street = self.contact.street;
            address.postcode = self.contact.postcode;
            address.country = self.contact.country;
            self.contact.city = nil;
            self.contact.street = nil;
            self.contact.postcode = nil;
            self.contact.country = nil;
            [_tableContents addObject:address];
        }
        else
        {
            Address *address = [self newEntryOfType:[Address class]];
            [_tableContents addObject:address];
        }
        
        [self didChangeValueForKey:@"_tableContents"];
    }
}

#pragma mark -
#pragma mark Table View

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_tableContents count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    // Get the row entry
    NSObject *entry = [_tableContents objectAtIndex:row];
    
    // Get the table column identifier
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"Entry"]) {
        // Pass the view controller as the owner so it can set up target/actions into this main controller object
        ContactEntryCellView *cellView = [tableView makeViewWithIdentifier:@"Entry" owner:self];
        
        // Set the popup button's menu title to the row number as a workaround so that it can be identified later
        [cellView.labelOptions setTitle:[NSString stringWithFormat:@"%ld", (long)row]];
        
        // Set up properties on the cellView based on the entry type
        if ([entry class] == [Email class])
        {
            NSArray *labelOptions = [NSArray arrayWithObjects:@"Home", @"Work", @"Other", nil];
            for (NSString *label in labelOptions)
            {
                NSInteger index = [cellView.labelOptions indexOfItemWithTitle:@"Custom..."];
                [cellView.label insertItemWithTitle:label atIndex:index];
            }
            [cellView.entry.cell setPlaceholderString:@"Email"];
            
            Email *email = [_tableContents objectAtIndex:row];
            if (email.type)
            {
                NSInteger index = [cellView.labelOptions indexOfItemWithTitle:@"Custom..."];
                if (![cellView.label itemWithTitle:email.type]) [cellView.label insertItemWithTitle:email.type atIndex:index];
                [cellView.label selectItemWithTitle:email.type];
            }
            if (email.address) cellView.entry.stringValue = email.address;
        }
        else if ([entry class] == [Phone class])
        {
            NSArray *labelOptions = [NSArray arrayWithObjects:@"Home", @"Work", @"Mobile", @"Home Fax", @"Work Fax", @"Other", nil];
            for (NSString *label in labelOptions)
            {
                NSInteger index = [cellView.labelOptions indexOfItemWithTitle:@"Custom..."];
                [cellView.label insertItemWithTitle:label atIndex:index];
            }
            [cellView.entry.cell setPlaceholderString:@"Phone"];

            Phone *phone = [_tableContents objectAtIndex:row];
            if (phone.type)
            {
                NSInteger index = [cellView.labelOptions indexOfItemWithTitle:@"Custom..."];
                if (![cellView.label itemWithTitle:phone.type]) [cellView.label insertItemWithTitle:phone.type atIndex:index];
                [cellView.label selectItemWithTitle:phone.type];
            }
            if (phone.number) cellView.entry.stringValue = phone.number;
        }
        else if ([entry class] == [Address class])
        {
            [cellView layoutViewForAddressMode:YES animated:NO];
            NSArray *labelOptions = [NSArray arrayWithObjects:@"Home", @"Work", @"Mobile", @"Home Fax", @"Work Fax", @"Other", nil];
            for (NSString *label in labelOptions)
            {
                NSInteger index = [cellView.labelOptions indexOfItemWithTitle:@"Custom..."];
                [cellView.label insertItemWithTitle:label atIndex:index];
            }
            [cellView.entry.cell setPlaceholderString:@"Street"];

            Address *address = [_tableContents objectAtIndex:row];
            if (address.type)
            {
                NSInteger index = [cellView.labelOptions indexOfItemWithTitle:@"Custom..."];
                if (![cellView.label itemWithTitle:address.type]) [cellView.label insertItemWithTitle:address.type atIndex:index];
                [cellView.label selectItemWithTitle:address.type];
            }
            if (address.street) cellView.entry.stringValue = address.street;
            if (address.city) cellView.city.stringValue = address.city;
            if (address.region) cellView.region.stringValue = address.region;
            if (address.postcode) cellView.postcode.stringValue = address.postcode;
            if (address.country) cellView.country.stringValue = address.country;
        }

        NSInteger index = [cellView.labelOptions indexOfItemWithTitle:@"Custom..."];
        [[cellView.label menu] insertItem:[NSMenuItem separatorItem] atIndex:index];

        return cellView;
    }
    else
    {
        NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    CGFloat height;
    if ([[_tableContents objectAtIndex:row] class] == [Address class]) {
        height = 93;
    } else {
        height = 30;
    }
    return height;
}

#pragma mark -
#pragma mark Action Methods

- (IBAction)addEntry:(id)sender
{
    NSInteger selectedRow = [_tableView rowForView:sender];
    NSInteger insertedRow = selectedRow + 1;
    id newEntry = [self newEntryOfType:[_tableContents objectAtIndex:selectedRow]];
    [_tableContents insertObject:newEntry atIndex:insertedRow];
    [_tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:insertedRow] withAnimation:NSTableViewAnimationSlideDown];
    
    // Update the popup button's menu title to its new row number for each entry
    for (int row = 0; row < [_tableContents count]; row++)
    {
        ContactEntryCellView *cellView = [_tableView viewAtColumn:0 row:row makeIfNecessary:NO];
        [cellView.labelOptions setTitle:[NSString stringWithFormat:@"%ld", (long)row]];
    }
}

- (IBAction)save:(id)sender
{
    self.needsSaving = YES;
    [self updateContactAttributes];
    [self.delegate closePopover:self];
}

- (IBAction)cancel:(id)sender
{
    self.needsSaving = NO;
    [self.delegate closePopover:self];
}

- (IBAction)addLabel:(id)sender
{
    if (_customLabelWindowController) return;
    
    // Workaround to determine the row of the table that was selected
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSInteger row = [[numberFormatter numberFromString:[[sender menu] title]] integerValue];
    
    // Store the row that called the custom label action
    _selectedRow = row;
    
    // Instantiate the custom label window controller and show the window
    _customLabelWindowController = [[NSWindowController alloc] initWithWindow:self.customLabelWindow];
    [_customLabelWindowController showWindow:nil];
}

- (IBAction)insertLabel:(id)sender
{
    ContactEntryCellView *cellView = [_tableView viewAtColumn:0 row:_selectedRow makeIfNecessary:NO];
    if (![self.customLabel.stringValue isEqualToString:@""])
    {
        NSInteger index = [cellView.labelOptions indexOfItemWithTitle:@"Custom..."] - 1;
        [cellView.label insertItemWithTitle:self.customLabel.stringValue atIndex:index];
        [cellView.label selectItemWithTitle:self.customLabel.stringValue];
    }
    [_customLabelWindowController close];
    _customLabelWindowController = nil;
}

- (IBAction)cancelLabel:(id)sender
{
    [_customLabelWindowController close];
    _customLabelWindowController = nil;
}

#pragma mark -
#pragma mark Helper Methods

- (id)newEntryOfType:(id)object
{
    if ([object class] == [Email class])
    {
        Email *newEntry = [self.delegate newEmail];
        newEntry.contact = self.contact;
        newEntry.type = @"Home";
        return newEntry;
    }
    else if ([object class] == [Phone class])
    {
        Phone *newEntry = [self.delegate newPhone];
        newEntry.contact = self.contact;
        newEntry.type = @"Home";
        return newEntry;
    }
    else if ([object class] == [Address class])
    {
        Address *newEntry = [self.delegate newAddress];
        newEntry.contact = self.contact;
        newEntry.type = @"Home";
        return newEntry;
    }

    NSLog(@"ERROR: Entry type is unknown!");
    return nil;
}

- (void)updateContactAttributes
{
    self.contact.image = [self.portraitImage.image TIFFRepresentation];
    self.contact.firstName = self.firstName.stringValue;
    self.contact.lastName = self.lastName.stringValue;
    self.contact.relation = self.relation.stringValue;
    self.contact.company = self.company.stringValue;

    if ([self.contact.firstName isEqualToString:@""]) self.contact.firstName = nil;
    if ([self.contact.lastName isEqualToString:@""])  self.contact.lastName = nil;
    if ([self.contact.relation isEqualToString:@""])  self.contact.relation = nil;
    if ([self.contact.company isEqualToString:@""])   self.contact.company = nil;

    for (int row = 0; row < [_tableContents count]; row++)
    {
        NSObject *entry = [_tableContents objectAtIndex:row];
        ContactEntryCellView *cellView = [_tableView viewAtColumn:0 row:row makeIfNecessary:NO];
        
        // Read the attributes from the cellView for the appropriate entry type
        if ([entry class] == [Email class])
        {
            Email *email = [_tableContents objectAtIndex:row];
            email.type = cellView.label.titleOfSelectedItem;
            email.address = cellView.entry.stringValue;
            if ([email.address isEqualToString:@""])
                [self.delegate deleteManagedObject:email];
        }
        else if ([entry class] == [Phone class])
        {
            Phone *phone = [_tableContents objectAtIndex:row];
            phone.type = cellView.label.titleOfSelectedItem;
            phone.number = cellView.entry.stringValue;
            if ([phone.number isEqualToString:@""])
                [self.delegate deleteManagedObject:phone];
        }
        else if ([entry class] == [Address class])
        {
            Address *address = [_tableContents objectAtIndex:row];
            address.type = cellView.label.titleOfSelectedItem;
            address.street = cellView.entry.stringValue;
            address.city = cellView.city.stringValue;
            address.region = cellView.region.stringValue;
            address.postcode = cellView.postcode.stringValue;
            address.country = cellView.country.stringValue;
            if ([address.fullAddress isEqualToString:@""])
                [self.delegate deleteManagedObject:address];
        }
    }
}

@end
