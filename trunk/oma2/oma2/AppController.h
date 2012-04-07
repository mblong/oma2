//
//  AppController.h
//  tst2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Foundation/Foundation.h>

// function prototypes for UI independent routines that we need
int comdec(char*);


@class PreferenceController;
@class DataWindowController;

@interface AppController : NSObject{
    
    PreferenceController *preferenceController;
    DataWindowController *dataWindowController;
    NSWindow *theWindow;
    NSUInteger last_return;
    NSString *sometext;
    
}

@property (assign) IBOutlet NSTextView *theCommands;
@property (assign) IBOutlet NSWindow *theWindow;
@property (copy) NSString *sometext; 

//-(void) textDidChange:(NSNotification *) pNotify;   

-(void) appendText:(NSString *) string; 
-(void) appendCText:(char *) string; 
-(id) whoami;


- (IBAction)showPrefs:(id)sender;
-(void) showDataWindow:(char*) windowname;
-(void) eraseWindow:(int) n;
-(void) dataWindowClosing;
@end

