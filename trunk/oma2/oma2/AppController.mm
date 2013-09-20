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
#import "StatusController.h"
#import "ImageBitmap.h"



AppController   *appController;
extern ImageBitmap iBitmap;
extern Image iBuffer;

@implementation AppController

@synthesize theCommands;
@synthesize theWindow;
@synthesize tool;
@synthesize preferenceController;



-(void)awakeFromNib{
    appController = [self whoami];
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

// this attempt to be notified when text changes in prefixes doesn't work
// It gets called once only when the window opens, not when the text changes
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
    if ([keyPath isEqualToString:@"macroPrefix"]) {
        
        const char* text = [[[change objectForKey:NSKeyValueChangeNewKey] stringValue] cStringUsingEncoding:NSASCIIStringEncoding];
        fullname((char*)text,LOAD_SAVE_PREFIX);
    }
}




-(id) whoami{
    return self;
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
    
    // figure out where to place image
    // window_placement needs to have the right position and size
    
    int windowHeight = iBitmap.getheight();
    int windowWidth = iBitmap.getwidth();
    float scaleWidth = (float)windowWidth/(float)screenRect.size.width;
    float scaleHeight = (float)windowHeight/(float)screenRect.size.height;
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
    
    DataWindowController* dataWindowController = [[DataWindowController alloc] initWithWindowNibName:@"DataWindow"];
    
    [windowArray addObject:dataWindowController];
    
    if(*windowname){
        NSString *text  = [[NSString alloc] initWithCString:windowname encoding:NSASCIIStringEncoding];
        [dataWindowController setWindowName:text] ; 
    } else{
         [dataWindowController setWindowName:@"Data"] ; 
    }
    
    [dataWindowController placeImage:window_placement];
    
    window_placement.origin.x += windowWidth;            // increment for next one
    /*
    if (window_placement.origin.x > screenRect.size.width){     //
        window_placement.origin.x = screenRect.origin.x + WINDOW_OFFSET;
        if(window_placement.origin.y - iBitmap.getheight() - TITLEBAR_HEIGHT > 0){
            window_placement.origin.y -= (iBitmap.getheight() + TITLEBAR_HEIGHT);
        } else{
            window_placement.origin.y = screenRect.size.height;
        }
    }
    */
    [dataWindowController showWindow:self];
    
}

-(void) updateDataWindow{
    iBitmap = iBuffer;
    [[windowArray lastObject] updateImage];
    [[windowArray lastObject] showWindow:self];
}

-(void) eraseWindow:(int) n{
    for (DataWindowController* thewindow in windowArray){
        [[thewindow window ] close];
    }
    [windowArray removeAllObjects];
    wraps=1;
    window_placement.origin.x = screenRect.origin.x+WINDOW_OFFSET;
    window_placement.origin.y = screenRect.size.height;
}

-(void) dataWindowClosing{
    //dataWindowController = nil;
}


@end
