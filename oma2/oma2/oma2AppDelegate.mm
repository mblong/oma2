//
//  oma2AppDelegate.m
//  oma2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "oma2AppDelegate.h"
#import "StatusController.h"
#import "oma2.h"
#import "UI.h"

#ifdef LJU3
#include "u3.h"
#endif

extern StatusController *statusController;
extern oma2UIData UIData;

// function prototypes for UI independent routines that we need
int loadprefs(char*);
int getpalettefile(char*);
void update_UI();
void setUpUIData();


@implementation oma2AppDelegate

@synthesize window = _window;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    int dcrawarg_c(int n, char* args);
    
    // Insert code here to initialize your application
    if(!statusController){
        statusController = [[StatusController alloc] initWithWindowNibName: @"Status"];
    }
    [statusController showWindow:self];
   
    NSRect frame = [[NSScreen mainScreen] visibleFrame];
    frame.origin.x += WINDOW_OFFSET;
    frame.size.width = COMMANDWIDTH;
    frame.size.height = COMMANDHEIGHT+TITLEBAR_HEIGHT;
    
    [[appController theWindow] setFrame:frame display:YES];

    
    
    char text[NEW_PREFIX_CHPERLN];
    extern char applicationPath[];		// this is the path to the directory that the program is running from
    extern char contentsPath[];         // this is the path to the Contents directory

    
    // set the directory to oma2.app
    NSString* contents = [[NSBundle mainBundle] bundlePath];
    strlcpy(contentsPath,[contents cStringUsingEncoding:NSASCIIStringEncoding],CHPERLN);
    chdir(contentsPath);
    strlcpy(applicationPath,[[contents stringByDeletingLastPathComponent] cStringUsingEncoding:NSASCIIStringEncoding],CHPERLN);
    strlcat(applicationPath,"/",CHPERLN);
    
    setUpUIData();
    
    // Load preferences
    strlcpy(text,SETTINGSFILE,NEW_PREFIX_CHPERLN);
    loadprefs(text);
    UIData.newwindowflag = 1;   // this default is set initially
    
    strlcpy(text,DCRAW_ARG,NEW_PREFIX_CHPERLN);
    dcrawarg_c(0,text);
    
    update_UI();

}

-(void) applicationWillTerminate:(NSNotification *)notification
{   
    char c=0;
    int savsettings(int n,char* args);
    savsettings(0,&c);
    // hardware dependent close operations
#ifdef LJU3
    extern HANDLE hDevice;
    extern int u3_connected;
    if(u3_connected)closeUSBConnection(hDevice);
#endif
    
    
    
}
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
    NSString *ext = [filename pathExtension];
    const char* cname = [filename cStringUsingEncoding:NSASCIIStringEncoding];
    const char* cext = [ext cStringUsingEncoding:NSASCIIStringEncoding];
    return dropped_file((char*)cext,(char*)cname);
}


@end
