//
//  oma2AppDelegate.m
//  oma2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "oma2AppDelegate.h"
#import "StatusController.h"

@implementation oma2AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    if(!statusController){
        statusController = [[StatusController alloc] initWithWindowNibName: @"Status"];
    }
    [statusController showWindow:self];

}


@end