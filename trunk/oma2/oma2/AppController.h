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
//@class StatusController;

@interface AppController : NSObject{
    
    PreferenceController *preferenceController;
    DataWindowController *dataWindowController;
    //StatusController    *statusController;
    NSWindow *__unsafe_unretained theWindow;
    NSUInteger last_return;
//    NSString *sometext;
    
}

@property (unsafe_unretained) IBOutlet NSTextView *theCommands;
@property (unsafe_unretained) IBOutlet NSWindow *theWindow;
//@property (copy) NSString *sometext;

@property int tool;     // the tool selected in the status window, used in DataView

//@property (copy) StatusController *statusController;

//-(void) textDidChange:(NSNotification *) pNotify;   

-(void) appendText:(NSString *) string; 
-(void) appendCText:(char *) string;
//-(void) updateCMin:(float) cmin Max:(float) cmax;
//-(void) updateAutoScale:(BOOL) val;


-(id) whoami;


- (IBAction)showPrefs:(id)sender;
-(void) showDataWindow:(char*) windowname;
-(void) eraseWindow:(int) n;
-(void) dataWindowClosing;
-(void) updateDataWindow;
@end

