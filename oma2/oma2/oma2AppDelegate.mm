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
    
    char text[NEW_PREFIX_CHPERLN];
    
    // set the directory to oma2.app
    strlcpy(text,[[[NSBundle mainBundle] bundlePath] cStringUsingEncoding:NSASCIIStringEncoding ],NEW_PREFIX_CHPERLN);
    chdir(text);
    
    setUpUIData();
    
    // Load preferences
    strlcpy(text,SETTINGSFILE,NEW_PREFIX_CHPERLN);
    loadprefs(text);
    
    strlcpy(text,DCRAW_ARG,NEW_PREFIX_CHPERLN);
    dcrawarg_c(0,text);
    
    update_UI();

}

-(void) applicationWillTerminate:(NSNotification *)notification
{   
    char c=0;
    int savsettings(int n,char* args);
    savsettings(0,&c);
    
}


@end
