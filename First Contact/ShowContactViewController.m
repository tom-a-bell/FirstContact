//
//  ShowContactViewController.m
//  First Contact
//
//  Created by Tom Bell on 19/06/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "AppDelegate.h"
#import "Contact.h"
#import "Email.h"
#import "Phone.h"
#import "Address.h"
#import "ShowContactViewController.h"

@implementation ShowContactViewController

- (IBAction)editContact:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate showEditPopoverWithContact:contact];
}

- (void)setContact:(Contact *)aContact
{
    contact = aContact;
    
    labelWidth  = 60.0;
    labelHeight = 17.0;
    labelIndent = 10.0;

    fieldWidth = 200.0;
    fieldHeight = 17.0;
    fieldIndent = labelIndent + labelWidth + 5.0;
    
    imageWidth  = 63.0;
    imageHeight = 63.0;
    imageIndent = 10.0;

    sectionSize = 10.0;
    
    NSSize viewSize = NSMakeSize(250.0, 10.0);
    [self setViewSize:viewSize];
    
    // Create a sort descriptor to sort the entries by label type
    NSSortDescriptor *sortByType = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:NO];
    
    if (contact.birthday)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        [self addEntry:[dateFormatter stringForObjectValue:contact.birthday] withLabel:@"Birthday"];
        [self addSectionBreak];
    }
    
    NSArray *addressList = [contact.hasAddress sortedArrayUsingDescriptors:@[sortByType]];
    if (addressList.count > 0)
    {
        for (Address *address in addressList)
            if ([self isValid:address.fullAddress])
                [self addEntry:address.fullAddress withLabel:address.type];
        [self addSectionBreak];
    }
    else if ([self isValid:contact.fullAddress])
    {
        [self addEntry:contact.fullAddress withLabel:@"Home"];
        [self addSectionBreak];
    }
    
    NSArray *phoneList = [contact.hasPhone sortedArrayUsingDescriptors:@[sortByType]];
    if (phoneList.count > 0)
    {
        for (Phone *phone in phoneList)
            if ([self isValid:phone.number])
                [self addEntry:phone.number withLabel:phone.type];
        [self addSectionBreak];
    }
    else if ([self isValid:contact.phone])
    {
        [self addEntry:contact.phone withLabel:@"Phone"];
        [self addSectionBreak];
    }
    
    NSArray *emailList = [contact.hasEmail sortedArrayUsingDescriptors:@[sortByType]];
    if (emailList.count > 0)
    {
        for (Email *email in emailList)
            if ([self isValid:email.address])
                [self addEntry:email.address withLabel:email.type];
        [self addSectionBreak];
    }
    else if ([self isValid:contact.email])
    {
        [self addEntry:contact.email withLabel:@"Email"];
        [self addSectionBreak];
    }

    if ([self isValid:contact.company] && contact.company != contact.fullName)
    {
        [self addEntry:contact.company];
    }

    [self addEntry:contact.fullName inBold:YES];

    [self addSectionBreak];
}

- (NSImageView *) addPortraitImage:(NSImage *)image
{
    NSSize size = self.view.frame.size;
    
    NSImageView *imageField = [[NSImageView alloc] initWithFrame:
                               NSMakeRect(imageIndent, size.height - imageHeight - 10, imageWidth, imageHeight)];
    [imageField setImage:image];
    [imageField setEditable:NO];
    
    [self.view addSubview:imageField];
    
    return imageField;
}

- (MouseDownTextField *) addEntry:(NSString *)entry
{
    return [self addEntry:entry inBold:NO];
}

- (MouseDownTextField *) addEntry:(NSString *)entry inBold:(BOOL)bold
{
    NSSize size = self.view.frame.size;
    
    MouseDownTextField *textField = [[MouseDownTextField alloc] initWithFrame:
                                     NSMakeRect(fieldIndent, size.height, fieldWidth, fieldHeight)];
    [textField setStringValue:[self validStringFor:entry]];
    [textField setBezeled:NO];
    [textField setDrawsBackground:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    if (bold) [textField setFont:[NSFont boldSystemFontOfSize:
                                 [NSFont systemFontSizeForControlSize:
                                 [[textField cell] controlSize]]]];
    [[textField cell] setWraps:YES];
    [[textField cell] setLineBreakMode:NSLineBreakByWordWrapping];
    [textField sizeToFit];
    
    [self.view addSubview:textField];
    
    // Set the view controller to be the text field delegate.
    textField.delegate = self;
    
    size.width  = MAX(textField.frame.size.width + fieldIndent + 10, size.width);
    size.height += textField.frame.size.height;
    [self setViewSize:size];
    
    return textField;
}

- (MouseDownTextField *) addEntry:(NSString *)entry
                        withLabel:(NSString *)label
{
    
    MouseDownTextField *textField = [self addEntry:entry inBold:NO];
    
    CGFloat xpos = labelIndent;
    CGFloat ypos = textField.frame.origin.y + textField.frame.size.height - fieldHeight + 1;

    MouseDownTextField *labelField = [[MouseDownTextField alloc] initWithFrame:
                                      NSMakeRect(xpos, ypos, labelWidth, labelHeight)];
    [labelField setStringValue:[self validStringFor:label]];
    [labelField setBezeled:NO];
    [labelField setDrawsBackground:NO];
    [labelField setEditable:NO];
    [labelField setSelectable:NO];
    [labelField setTextColor:[NSColor grayColor]];
    [labelField setFont:[NSFont boldSystemFontOfSize:
                         [NSFont systemFontSizeForControlSize:[[labelField cell] controlSize]]]];
    [[labelField cell] setWraps:YES];
    [[labelField cell] setLineBreakMode:NSLineBreakByWordWrapping];
    [[labelField cell] setAlignment:NSRightTextAlignment];

    [labelField sizeToFit];
    xpos += labelWidth - labelField.frame.size.width;
    [labelField setFrameOrigin:NSMakePoint(xpos, ypos)];
    
    [self.view addSubview:labelField];
    
    NSSize size = self.view.frame.size;
    size.width = MAX(labelField.frame.size.width + textField.frame.size.width + 40, size.width);
    [self setViewSizeAlignRight:size];
    
    return textField;
}

- (void)addSectionBreak
{
    [self setViewSize:NSMakeSize(self.view.frame.size.width, self.view.frame.size.height + sectionSize)];
}

- (void)setViewSize:(NSSize)size
{
    NSRect oldFrame = self.view.frame;
    NSRect newFrame = NSMakeRect(NSMinX(oldFrame),
                                 NSMaxY(oldFrame) - size.height,
                                 size.width, size.height);
    [self.view setFrame:newFrame];
    [self.view needsDisplay];
}

- (void)setViewSizeAlignRight:(NSSize)size
{
    NSRect oldFrame = self.view.frame;
    NSRect newFrame = NSMakeRect(NSMaxX(oldFrame) - size.width,
                                 NSMaxY(oldFrame) - size.height,
                                 size.width, size.height);
    [self.view setFrame:newFrame];
    [self.view needsDisplay];
}

- (BOOL)isValid:(NSString *)entry
{
    return (entry != nil && ![entry isEqualToString:@""]);
}

- (NSString *)validStringFor:(NSString *)entry
{
    return entry;
//    if (entry && ![entry isEqualToString:@""]) return entry;
//    return @"";
}

#pragma mark -
#pragma mark MouseDownTextField Delegate

- (void)mouseDownTextFieldClicked:(MouseDownTextField *)textField
{
    // Change the text color to grey
    [textField setTextColor:[NSColor grayColor]];

    // Copy the text to the pasteboard
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pasteboard setString:textField.stringValue forType:NSStringPboardType];
}

- (void)mouseUpTextFieldClicked:(MouseDownTextField *)textField
{
    // Change the text color back to black
    [textField setTextColor:[NSColor blackColor]];
}

@end
