//
//  VariablesWindowController.h
//  oma2
//
//  Created by Marshall Long on 12/3/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VariablesWindowController : NSWindowController



@property (weak) IBOutlet NSTextField *VariablesLabel;
//@property (strong) IBOutlet NSTextView *VariablesText;

- (void) updateVariableList:(const char*) string;

@end

