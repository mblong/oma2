//
//  PreferenceController.m
//  oma2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "PreferenceController.h"

extern oma2UIData UIData;

@implementation PreferenceController
@synthesize savePrefix;
@synthesize getPrefix;
@synthesize macroPrefix;
@synthesize settingsPrefix;
@synthesize getSuffix;
@synthesize macroSuffix;
@synthesize settingsSuffix;
@synthesize saveSuffix;

@synthesize sometext;

@synthesize paletteSelected;
@synthesize transparencyValue;
@synthesize  transparent;

@synthesize  highlightSaturatedState;
@synthesize  highlightColor;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    //[[self window] display];
    [self showWindow:self];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)saveNewSettings:(id)sender {
    const char* text = [[savePrefix stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    fullname((char*)text,LOAD_SAVE_PREFIX);
    text = [[getPrefix stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    fullname((char*)text,LOAD_GET_PREFIX);
    text = [[saveSuffix stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    fullname((char*)text,LOAD_SAVE_SUFFIX);
    text = [[getSuffix stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    fullname((char*)text,LOAD_GET_SUFFIX);
    
    text = [[macroPrefix stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    fullname((char*)text,LOAD_MACRO_PREFIX);
    text = [[settingsPrefix stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    fullname((char*)text,LOAD_SETTINGS_PREFIX);
    text = [[macroSuffix stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    fullname((char*)text,LOAD_MACRO_SUFFIX);
    text = [[settingsSuffix stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
    fullname((char*)text,LOAD_SETTINGS_SUFFIX);
    
    int number = (int)[transparencyValue integerValue];
    if (number < 0) number = 0;
    if (number > 100) number = 100;
    
    UIData.alphaValue = 1. - (float)number/100.;
    
    // close the window here
    //[[self window] close];  // this doesn't work -- window is nil
    // this does work -- I don't understand this; I guess because the window was opened in the appController
    [[[appController preferenceController] window] close];
    
}

- (IBAction)forgetNewSettings:(id)sender {
    [[[appController preferenceController] window] close];
}

- (IBAction)selectPalette:(id)sender{
    int palette = (int)[paletteSelected selectedColumn]*4 + (int)[paletteSelected selectedRow];
    UIData.thepalette = palette;
    update_UI();
}

- (void) fillInUIData{
    
    [savePrefix setStringValue:[NSString stringWithCString:UIData.saveprefixbuf encoding:NSASCIIStringEncoding]];
    [getPrefix setStringValue:[NSString stringWithCString:UIData.getprefixbuf encoding:NSASCIIStringEncoding]];
    [settingsPrefix setStringValue:[NSString stringWithCString:UIData.graphicsprefixbuf encoding:NSASCIIStringEncoding]];
    [macroPrefix setStringValue:[NSString stringWithCString:UIData.macroprefixbuf encoding:NSASCIIStringEncoding]];
    [saveSuffix setStringValue:[NSString stringWithCString:UIData.savesuffixbuf encoding:NSASCIIStringEncoding]];
    [getSuffix setStringValue:[NSString stringWithCString:UIData.getsuffixbuf encoding:NSASCIIStringEncoding]];
    [settingsSuffix setStringValue:[NSString stringWithCString:UIData.graphicssuffixbuf encoding:NSASCIIStringEncoding]];
    [macroSuffix setStringValue:[NSString stringWithCString:UIData.macrosuffixbuf encoding:NSASCIIStringEncoding]];
    
    int row = UIData.thepalette%4;
    int col = UIData.thepalette/4;
    [[self paletteSelected] selectCellAtRow:row column:col];
    
    [transparencyValue setStringValue:[NSString stringWithFormat:@"%.0f",100.*(1.-UIData.alphaValue)]];
    
    [highlightSaturatedState setState:UIData.highlightSaturated];
    [highlightColor setColor: [NSColor colorWithRed:UIData.highlightSaturatedRed/255.
                                              green:UIData.highlightSaturatedGreen/255.
                                              blue:UIData.highlightSaturatedBlue/255. alpha:1.0]];
    
}

-(BOOL) acceptsFirstResponder{
    return YES;
}

- (IBAction)highlightSaturatedCheckbox:(id)sender {
    if([highlightSaturatedState state] )
        UIData.highlightSaturated = 1;
    else
        UIData.highlightSaturated = 0;
}

- (IBAction)highlightColorSet:(id)sender {
    UIData.highlightSaturatedRed = 255*[[highlightColor color] redComponent];
    UIData.highlightSaturatedGreen = 255*[[highlightColor color] greenComponent];
    UIData.highlightSaturatedBlue = 255*[[highlightColor color] blueComponent];
}

@end
