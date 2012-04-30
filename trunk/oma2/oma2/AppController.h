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
    
    PreferenceController *__strong preferenceController;
    
    NSWindow *__strong theWindow;
    NSUInteger last_return;
    NSUInteger wraps;
    
    NSMutableArray *windowArray; 
    
    NSRect window_placement;
    NSRect screenRect;

}
@property (strong) PreferenceController *preferenceController;
@property (strong) IBOutlet NSTextView *theCommands;
@property (strong) IBOutlet NSWindow *theWindow;
@property int tool;     // the tool selected in the status window, used in DataView


-(void) appendText:(NSString *) string; 
-(void) appendCText:(char *) string;


-(id) whoami;


- (IBAction)showPrefs:(id)sender;

-(void) showDataWindow:(char*) windowname;
-(void) eraseWindow:(int) n;
-(void) dataWindowClosing;
-(void) updateDataWindow;

@end

