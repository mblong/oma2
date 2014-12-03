//
//  VariablesWindowController.m
//  oma2
//
//  Created by Marshall Long on 12/3/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//

#import "VariablesWindowController.h"
#import "AppController.h"

extern AppController *appController;

@interface VariablesWindowController ()

@end

@implementation VariablesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@synthesize VariablesLabel;
//@synthesize VariablesText;

- (void) updateVariableList:(const char*) string{
    //[VariablesLabel.cell setScrollable:true];
    [VariablesLabel setStringValue:[NSString stringWithCString: string encoding:NSASCIIStringEncoding]];
    
    //[VariablesText setEditable:true];
    //[VariablesText insertText: [NSString stringWithCString: string encoding:NSASCIIStringEncoding]];
    //[VariablesText.textStorage.mutableString setString:[NSString stringWithCString: string encoding:NSASCIIStringEncoding]];
    //[VariablesText setEditable:false];
    //[self showWindow:self];
}


- (void)keyDown:(NSEvent *)anEvent{
    [[appController theWindow] sendEvent: anEvent];
}


@end
