//
//  AppController.h
//  tst2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "oma2.h"

// This isn't the right way to do this
#define TITLEBAR_HEIGHT 20

#define WINDOW_OFFSET 20


// function prototypes for UI independent routines that we need
int comdec(char*);

// this is the main control for oma
// its window is the "oma2" (i.e, command) window



@class PreferenceController;
@class DataWindowController;

@interface AppController : NSObject{
    
    PreferenceController *__strong preferenceController;
    
    NSWindow *__strong theWindow;
    NSUInteger last_return;
    NSUInteger wraps;
    
    NSMutableArray *windowArray;
    
    NSRect window_placement;
    NSRect screenRect;
    NSTextView *__strong theCommands;
    char oma2Command[CHPERLN];

}
@property (strong) PreferenceController *preferenceController;
@property (strong) IBOutlet NSTextView *theCommands;
@property (strong) IBOutlet NSWindow *theWindow;
@property int tool;     // the tool selected in the status window, used in DataView
@property NSMutableArray *windowArray;

-(void) appendText:(NSString *) string; 
-(void) appendCText:(char *) string;




- (IBAction)showPrefs:(id)sender;

- (IBAction)plotRows:(id)sender;
- (IBAction)plotCols:(id)sender;

-(void) showDataWindow:(char*) windowname;
-(void) eraseWindow:(int) n;
-(void) dataWindowClosing;
-(void) updateDataWindow;

@end

