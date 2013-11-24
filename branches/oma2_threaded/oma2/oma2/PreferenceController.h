//
//  PreferenceController.h
//  oma2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "image_support.h"
#import "oma2.h"

@interface PreferenceController : NSWindowController{
    NSTextField *__weak savePrefix;
    NSTextField *__weak getPrefix;
    NSTextField *__weak macroPrefix;
    NSTextField *__weak settingsPrefix;
    
    NSTextField *__weak saveSuffix;
    NSTextField *__weak getSuffix;
    NSTextField *__weak macroSuffix;
    NSTextField *__weak settingsSuffix;
    
    NSString *sometext;
}

- (IBAction)newSavePrefix:(id)sender;


@property (weak) IBOutlet NSTextField *savePrefix;
@property (weak) IBOutlet NSTextField *getPrefix;
@property (weak) IBOutlet NSTextField *macroPrefix;
@property (weak) IBOutlet NSTextField *settingsPrefix;


@property (weak) IBOutlet NSTextField *saveSuffix;
@property (weak) IBOutlet NSTextField *getSuffix;
@property (weak) IBOutlet NSTextField *macroSuffix;
@property (weak) IBOutlet NSTextField *settingsSuffix;

@property (copy) IBOutlet NSString *sometext;

- (void) fillInUIData;


@end
