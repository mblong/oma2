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
#define TITLEBAR_HEIGHT 28

#define WINDOW_OFFSET 20

// width of the command window
#define COMMANDWIDTH 600
#define COMMANDHEIGHT 354


// function prototypes for UI independent routines that we need
int comdec(char*);

// this is the main control for oma
// its window is the "oma2" (i.e, command) window


@class VariablesWindowController;
@class PreferenceController;
@class DataWindowController;
@class DrawingWindowController;
@class CommandView;
@class ColorImageOptionsController;
#ifdef ZWO
@class ZwoOptions;
#endif
@class Histogram;

@interface AppController : NSObject
{
    PreferenceController *__strong preferenceController;
    
    NSWindow *__strong theWindow;
    //NSUInteger last_return;
    NSUInteger wraps;
    
    NSMutableArray *windowArray;
    
    NSRect window_placement;
    NSRect screenRect;
    CommandView *__strong theCommands;
    //char oma2Command[CHPERLN];
}

@property (strong) VariablesWindowController *variablesWindowController;
@property (strong) PreferenceController *preferenceController;
@property (strong) ColorImageOptionsController *colorImageOptionsController;
@property (strong) IBOutlet CommandView *theCommands;
@property (strong) IBOutlet NSWindow *theWindow;
#ifdef ZWO
@property (strong) ZwoOptions *zwoOptions;
#endif

@property (strong) Histogram *histogram;

@property int tool;     // the tool selected in the status window, used in DataView
@property NSMutableArray *windowArray;
//@property NSUInteger last_return;

-(void) appendText:(NSString *) string; 
-(void) appendCText:(char *) string;


- (IBAction)showPrefs:(id)sender;

- (IBAction)plotRows:(id)sender;
- (IBAction)plotCols:(id)sender;
-(void) plotLineFrom:(NSPoint) start To: (NSPoint) end;
- (IBAction)plotContours:(id)sender;

- (IBAction)saveData:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)startHistogram:(id)sender;


-(void) showDataWindow:(char*) windowname;
-(void) labelDataWindow: (char*) theLabel;
-(void) setAlpha: (float) newAlpha;
-(void) labelMinMax;

-(void) eraseWindow:(int) n;
-(void) dataWindowClosing;
-(void) updateDataWindow;
-(void) updateModifiedDataWindow;
-(void) updateVariablesWindow;
-(void) updateStatusWindow;
-(void) startVariablesWindow;
#ifdef ZWO
-(void) startZwoOptionsWindow;
-(void) updateZwo;
-(void) closeZwoWindow;
-(void) updateZwoTimer:(int) n;
-(void) updateZwoFwhm:(float) value;
-(void) updateZwoSize:(float)size andEllipticity: (float)ellipticity;
#endif

-(void) updateHistogram;
-(IBAction) startHistogram;

-(int) saveDataWindowToPdf: (char*) fileName;

-(void) windowDidBecomeKey:(NSNotification *)note;

@end

