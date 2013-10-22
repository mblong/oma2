//
//  AppController.m
//  oma2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "AppController.h"
#import "PreferenceController.h"
#import "DataWindowController.h"
#import "DrawingWindowController.h"
#import "StatusController.h"
#import "ImageBitmap.h"
#import "DataView.h"



AppController   *appController;
extern ImageBitmap iBitmap;
extern Image iBuffer;
extern oma2UIData UIData;

@implementation AppController

@synthesize theCommands;
@synthesize theWindow;
@synthesize tool;
@synthesize preferenceController;
@synthesize windowArray;


-(void)awakeFromNib{
    // this global lets the UI independent code get in touch with us
    // see definitions in UI.h -- these defines are used in the UI independent part of the code
    appController = self;
    [self appendText: @"OMA2>"];
    
    NSScreen *mainScreen = [NSScreen mainScreen];
    screenRect = [mainScreen visibleFrame];
    window_placement.origin.x = screenRect.origin.x+WINDOW_OFFSET;
    window_placement.origin.y = screenRect.size.height;
    wraps = 1;
    
    windowArray = [[NSMutableArray alloc] initWithCapacity:10];
}

- (IBAction)showPrefs:(id)sender{
    if(!preferenceController){
        preferenceController = [[PreferenceController alloc] initWithWindowNibName:@"Preferences"];
    }
    
    // this attempt to be notified when text changes in prefixes doesn't work
    // It gets called once only when the window opens, not when the text changes
    [preferenceController addObserver:self
                           forKeyPath:@"macroPrefix"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
    
    [preferenceController showWindow:self];
    [preferenceController fillInUIData];
}

- (IBAction)plotRows:(id)sender{
    NSWindow* activekey = [NSApp keyWindow];
    NSWindow* activemain = [NSApp mainWindow];
    int key = -1;
    int main = -1;
    int i=0;
    for (id thewindowController in windowArray){
        if( [thewindowController window ] == activekey) key=i;
        i++;
    }
    i=0;
    for (id thewindowController in windowArray){
        if( [thewindowController window ] == activemain) main=i;
        
        i++;
    }

    if (key == -1) {
        return;
    }

    if ([windowArray[key] isKindOfClass:[DataWindowController class]]){
        NSLog(@"%d %d ",key,main);
    } else {
        return; // active window wasn't a data window
    }

 // figure out where to place image
 // window_placement needs to have the right position and size
    NSSize theWindowSize = [ [ activemain contentView ] frame ].size;
    
 
    int windowHeight = 256;
    int windowWidth = theWindowSize.width;
    
    //DataView* activeView = [activemain imageView ];

    
    // now, figure out where to place the window
    if(window_placement.origin.x == WINDOW_OFFSET+screenRect.origin.x) {   // left column
        window_placement.origin.y -= (windowHeight+TITLEBAR_HEIGHT);
    }
    
    window_placement=NSMakeRect(window_placement.origin.x,
                                window_placement.origin.y,
                                windowWidth, windowHeight+TITLEBAR_HEIGHT);
    
    if (window_placement.origin.x+windowWidth>screenRect.size.width) {
        window_placement.origin.x = screenRect.origin.x + WINDOW_OFFSET;
        
        if(window_placement.origin.y - windowHeight - TITLEBAR_HEIGHT > 0){
            window_placement.origin.y -= (windowHeight + TITLEBAR_HEIGHT);
        } else{
            wraps++;
            window_placement.origin.y = screenRect.size.height
            -windowHeight- wraps*TITLEBAR_HEIGHT; // wrap to top
        }
        
    }
    
    // create a new window controller object
    DrawingWindowController* rowWindowController = [[DrawingWindowController alloc] initWithWindowNibName:@"DrawingWindow"];
    
    // add that to the array of windows
    [windowArray addObject:rowWindowController];
    
    // name the window appropriately
    [rowWindowController setWindowName:@"Line Graphics"] ;
    // tell the window who its data controller is
    [rowWindowController setDataWindowController:windowArray[key]];
    
    // display the data
    [rowWindowController placeRowDrawing:window_placement];
    
    window_placement.origin.x += windowWidth;            // increment for next one
    
    [rowWindowController showWindow:self];
    tool = CROSS;
    UIData.toolselected = tool;
    [statusController setTool_selected:tool];
    [[statusController toolSelected] selectCellAtRow:0 column:tool];


    //NSLog(@"%d %d ",key,main);
    
    
}

- (IBAction)plotCols:(id)sender{
    NSWindow* activekey = [NSApp keyWindow];
    NSWindow* activemain = [NSApp mainWindow];
    int key = -1;
    int main = -1;
    int i=0;
    for (id thewindowController in windowArray){
        if( [thewindowController window ] == activekey) key=i;
        i++;
    }
    i=0;
    for (id thewindowController in windowArray){
        if( [thewindowController window ] == activemain) main=i;
        
        i++;
    }
    
    if (key == -1) {
        return;
    }
    
    if ([windowArray[key] isKindOfClass:[DataWindowController class]]){
        NSLog(@"%d %d ",key,main);
    } else {
        return; // active window wasn't a data window
    }
    
    // figure out where to place image
    // window_placement needs to have the right position and size
    NSSize theWindowSize = [ [ activemain contentView ] frame ].size;
    
    int windowHeight = 256;
    int windowWidth = theWindowSize.height;
    
    //DataView* activeView = [activemain imageView ];
    
    
    // now, figure out where to place the window
    if(window_placement.origin.x == WINDOW_OFFSET+screenRect.origin.x) {   // left column
        window_placement.origin.y -= (windowHeight+TITLEBAR_HEIGHT);
    }
    
    window_placement=NSMakeRect(window_placement.origin.x,
                                window_placement.origin.y,
                                windowWidth, windowHeight+TITLEBAR_HEIGHT);
    
    if (window_placement.origin.x+windowWidth>screenRect.size.width) {
        window_placement.origin.x = screenRect.origin.x + WINDOW_OFFSET;
        
        if(window_placement.origin.y - windowHeight - TITLEBAR_HEIGHT > 0){
            window_placement.origin.y -= (windowHeight + TITLEBAR_HEIGHT);
        } else{
            wraps++;
            window_placement.origin.y = screenRect.size.height
            -windowHeight- wraps*TITLEBAR_HEIGHT; // wrap to top
        }
        
    }
    
    // create a new window controller object
    DrawingWindowController* colWindowController = [[DrawingWindowController alloc] initWithWindowNibName:@"DrawingWindow"];
    
    // add that to the array of windows
    [windowArray addObject:colWindowController];
    
    // name the window appropriately
    [colWindowController setWindowName:@"Line Graphics"] ;
    // tell the window who its data controller is
    [colWindowController setDataWindowController:windowArray[key]];
    
    // display the data
    [colWindowController placeColDrawing:window_placement];
    
    window_placement.origin.x += windowWidth;            // increment for next one
    
    [colWindowController showWindow:self];
    tool = CROSS;
    UIData.toolselected = tool;
    [statusController setTool_selected:tool];
    [[statusController toolSelected] selectCellAtRow:0 column:tool];
    
    
    //NSLog(@"%d %d ",key,main);
    
    
}

// this attempt to be notified when text changes in prefixes doesn't work
// It gets called once only when the window opens, not when the text changes
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"macroPrefix"]) {
        
        const char* text = [[change[NSKeyValueChangeNewKey] stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
        fullname((char*)text,LOAD_SAVE_PREFIX);
    }
}


-(void) appendText:(NSString *) string{
    last_return += [string length];
    [[[theCommands textStorage] mutableString] appendString: string];
}

-(void) appendCText:(char *) string{
    NSString *reply = [[NSString alloc] initWithCString:string encoding:NSASCIIStringEncoding];
    last_return += [reply length];
    [[[theCommands textStorage] mutableString] appendString: reply];
}

-(void) textDidChange:(NSNotification *) pNotify {
    
    NSString *text  = [[theCommands textStorage] string];
    NSString *ch = [text substringFromIndex:[text length] - 1];
    
    if([ch isEqualToString:@"\n"]){
        NSString *command = [text substringFromIndex:last_return];
        last_return = [text length];
        // pass this to the command decoder
        char* cmd = (char*) [command cStringUsingEncoding:NSASCIIStringEncoding];
        // replace the \n with an EOL
        cmd[strlen(cmd)-1] = 0;
        strlcpy(oma2Command, cmd, CHPERLN);
        int returnVal = comdec((char*) oma2Command);
        
        if (returnVal < GET_MACRO_LINE ) {
            [self appendText: @"OMA2>"];
        }
        
        
    }
    
}

-(void) showDataWindow: (char*) windowname{
    // come here from the DISPLAY command
    extern int newWindowFlag;
    
    if (!newWindowFlag && [windowArray count]) {    // put the current bitmap in the last window if there is one
        [[windowArray lastObject] updateImage];
        [[windowArray lastObject] showWindow:self];
        return;
    }
    // delete the first window if this will take us over the max limit
    
    if ([windowArray count] == MAX_WINDOW_COUNT) {
        [self eraseWindow:0];
    }
    
    // figure out where to place image
    // window_placement needs to have the right position and size
    
    // this is for possibly scaling down images that won't fit on screen
    int windowHeight = iBitmap.getheight();
    int windowWidth = iBitmap.getwidth();
    float scaleWidth = (float)windowWidth/(float)screenRect.size.width;
    // leave a little space at the bottom of the sreen
    float scaleHeight = (float)windowHeight/(float)(screenRect.size.height-2*TITLEBAR_HEIGHT);
    float scaleWindow = 1.0;
    if (scaleHeight > 1.0 || scaleWidth > 1.0) {
        if(scaleHeight > scaleWidth)
            scaleWindow = scaleHeight;
        else
            scaleWindow = scaleWidth;
        windowHeight /= scaleWindow;
        windowWidth /= scaleWindow;
        char txt[128];
        sprintf(txt," Window scaled by %f\n",scaleWindow);
        [self appendCText:txt];
        
    }
    
    // now, figure out where to place the window
    if(window_placement.origin.x == WINDOW_OFFSET+screenRect.origin.x) {   // left column
        window_placement.origin.y -= (windowHeight+TITLEBAR_HEIGHT);
    }
    
    window_placement=NSMakeRect(window_placement.origin.x, 
                                window_placement.origin.y,
                                windowWidth, windowHeight+TITLEBAR_HEIGHT);
    
    if (window_placement.origin.x+windowWidth>screenRect.size.width) {
        window_placement.origin.x = screenRect.origin.x + WINDOW_OFFSET;
        
        if(window_placement.origin.y - windowHeight - TITLEBAR_HEIGHT > 0){
            window_placement.origin.y -= (windowHeight + TITLEBAR_HEIGHT);
        } else{
            wraps++;
            window_placement.origin.y = screenRect.size.height 
             -windowHeight- wraps*TITLEBAR_HEIGHT; // wrap to top
        }
         
    }
    
    // create a new window controller object
    DataWindowController* dataWindowController = [[DataWindowController alloc] initWithWindowNibName:@"DataWindow"];
    
    // add that to the array of windows
    [windowArray addObject:dataWindowController];
    
    // name the window appropriately
    if(*windowname){
        NSString *text  = [[NSString alloc] initWithCString:windowname encoding:NSASCIIStringEncoding];
        [dataWindowController setWindowName:text] ; 
    } else{
         [dataWindowController setWindowName:@"Data"] ; 
    }
    
    // display the data
    [dataWindowController placeImage:window_placement];
    
    window_placement.origin.x += windowWidth;            // increment for next one

    [dataWindowController showWindow:self];
    
}

-(void) updateDataWindow{
    // call this as needed when redisplaying the current image from events in the status window
    iBitmap = iBuffer;
    [[windowArray lastObject] updateImage];
    [[windowArray lastObject] showWindow:self];
}

-(void) eraseWindow:(int) n{
    if (n < 0) {            // erase everything
        for (id thewindow in windowArray){
            if ([thewindow isKindOfClass:[DataWindowController class]]){
                [thewindow setHasRowPlot:CLOSE_CLEANUP_DONE];
            }
            if ([thewindow isKindOfClass:[DrawingWindowController class]]){
                [thewindow setDrawingType:CLOSE_CLEANUP_DONE];
            }
            [[thewindow window ] close];
        }
        [windowArray removeAllObjects];
        wraps=1;
        window_placement.origin.x = screenRect.origin.x+WINDOW_OFFSET;
        window_placement.origin.y = screenRect.size.height;
        return;
    }
    
    if (n < [windowArray count]) {
        id thewindowController = windowArray[n];
        if ([thewindowController isKindOfClass:[DataWindowController class]]){
            // erasing a data window
            // check to see if this has any row or column plots
            if([thewindowController hasRowPlot] >=0){
                // this data window is going away, so don't leave the pointer laying around
                [[[(DataWindowController*)thewindowController imageView] rowWindowController] setDataWindowController:NULL];
            }
            if([thewindowController hasColPlot] >=0){
                // this data window is going away, so don't leave the pointer laying around
                [[[(DataWindowController*)thewindowController imageView] colWindowController] setDataWindowController:NULL];
            }
            // signal that we are done with the housekeeping
            [thewindowController setHasRowPlot:CLOSE_CLEANUP_DONE];

        }
        
        if ([thewindowController isKindOfClass:[DrawingWindowController class]]){
            // if we are erasing a row or column plot, let the data window know they are gone
            if([thewindowController drawingType] == ROW_DRAWING){
                [[thewindowController dataWindowController] setHasRowPlot:-1];
                [[[thewindowController dataWindowController] imageView] setRowLine:-1];
                [[[thewindowController dataWindowController] imageView] setRowWindowController:NULL];
            }
            if([thewindowController drawingType] == COL_DRAWING){
                [[thewindowController dataWindowController] setHasColPlot:-1];
                [[[thewindowController dataWindowController] imageView] setColLine:-1];
                [[[thewindowController dataWindowController] imageView] setColWindowController:NULL];
            }
            // signal that we are done with the housekeeping
            [thewindowController setDrawingType:CLOSE_CLEANUP_DONE];

            [[[thewindowController dataWindowController] imageView] setNeedsDisplay:YES];
        }
        
        [[thewindowController window ] close];
        [windowArray removeObjectAtIndex:n];

    }
    if([windowArray count] == 0){
        wraps=1;
        window_placement.origin.x = screenRect.origin.x+WINDOW_OFFSET;
        window_placement.origin.y = screenRect.size.height;
    }

}

-(void) dataWindowClosing{
    //dataWindowController = nil;
}


@end
