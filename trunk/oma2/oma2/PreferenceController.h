//
//  PreferenceController.h
//  oma2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "image_support.h"

@interface PreferenceController : NSWindowController{
    NSTextField *savePrefix;
    NSTextField *getPrefix;
    NSTextField *macroPrefix;
    NSTextField *settingsPrefix;
    
    NSTextField *saveSuffix;
    NSTextField *getSuffix;
    NSTextField *macroSuffix;
    NSTextField *settingsSuffix;
}

- (IBAction)newSavePrefix:(id)sender;


@property (assign) IBOutlet NSTextField *savePrefix;
@property (assign) IBOutlet NSTextField *getPrefix;
@property (assign) IBOutlet NSTextField *macroPrefix;
@property (assign) IBOutlet NSTextField *settingsPrefix;


@property (assign) IBOutlet NSTextField *saveSuffix;
@property (assign) IBOutlet NSTextField *getSuffix;
@property (assign) IBOutlet NSTextField *macroSuffix;
@property (assign) IBOutlet NSTextField *settingsSuffix;


@end
