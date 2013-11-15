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
    [self fillInUIData];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)newSavePrefix:(id)sender {
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


}

- (void) fillInUIData{
    [[self savePrefix] setStringValue:[[NSString alloc]initWithCString:UIData.saveprefixbuf 
                                                              encoding:NSASCIIStringEncoding]];
    [[self getPrefix] setStringValue:[[NSString alloc]initWithCString:UIData.getprefixbuf 
                                                              encoding:NSASCIIStringEncoding]];
    [[self settingsPrefix] setStringValue:[[NSString alloc]initWithCString:UIData.graphicsprefixbuf 
                                                                  encoding:NSASCIIStringEncoding]];
    [[self macroPrefix] setStringValue:[[NSString alloc]initWithCString:UIData.macroprefixbuf 
                                                              encoding:NSASCIIStringEncoding]];
    [[self saveSuffix] setStringValue:[[NSString alloc]initWithCString:UIData.savesuffixbuf 
                                                              encoding:NSASCIIStringEncoding]];
    [[self getSuffix] setStringValue:[[NSString alloc]initWithCString:UIData.getsuffixbuf 
                                                             encoding:NSASCIIStringEncoding]];
    [[self settingsSuffix] setStringValue:[[NSString alloc]initWithCString:UIData.graphicssuffixbuf 
                                                                  encoding:NSASCIIStringEncoding]];
    [[self macroSuffix] setStringValue:[[NSString alloc]initWithCString:UIData.macrosuffixbuf 
                                                               encoding:NSASCIIStringEncoding]];
}

-(BOOL) acceptsFirstResponder{
    return YES;
}


- (void)keyDown:(NSEvent *)anEvent{
    
    [super keyDown:anEvent];
    
}
@end
