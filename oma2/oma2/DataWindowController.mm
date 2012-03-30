//
//  DataWindowController.m
//  oma2
//
//  Created by Marshall Long on 3/29/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "DataWindowController.h"

@implementation DataWindowController

@synthesize  windowName;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.

        [[self window] setTitle:windowName];
    }
    
    return self;
}

-(void)awakeFromNib{
    
}

- (void)dealloc
{
    NSLog(@"deallocate DataWindowController");
    [super dealloc];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [[self window] setTitle:windowName];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (void) windowWillClose:(NSNotification *) notification
{
    NSWindowController *theWindowController = [[notification object] delegate];
    
    [theWindowController release];
    //[super dealloc];
    //[myArrayOfWindowControllers removeObject: theWindowController];
}


@end
