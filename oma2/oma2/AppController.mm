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
@synthesize sometext;

//@synthesize statusController;



- (IBAction)showPrefs:(id)sender{
    if(!preferenceController){
        preferenceController = [[PreferenceController alloc] initWithWindowNibName:@"Preferences"];
    }
    
    [preferenceController addObserver:self
          forKeyPath:@"macroPrefix"
             options:NSKeyValueObservingOptionNew
             context:NULL];

    [preferenceController showWindow:self];
    
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




-(void)awakeFromNib{
    appController = [self whoami];
    [self appendText: @"OMA2>"];
    /*
    if(!statusController){
        statusController = [[StatusController alloc] initWithWindowNibName: @"Status"];
    }
    [statusController showWindow:self];
     */
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
    [reply release];
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
        comdec((char*) cmd);
        [self appendText: @"OMA2>"];
    }
}

-(void) showDataWindow: (char*) windowname{
    //if(!dataWindowController){
        dataWindowController = [[DataWindowController alloc] initWithWindowNibName:@"DataWindow"];
    //}
    //NSLog(@"%ld",[dataWindowController retainCount]);
    if(*windowname){
        NSString *text  = [[NSString alloc] initWithCString:windowname encoding:NSASCIIStringEncoding];
        [dataWindowController setWindowName:text] ; 
        [text release];
    } else{
         [dataWindowController setWindowName:@"Data"] ; 
    }
    
    //[[dataWindowController window] setTitle:[dataWindowController windowName]];
    [dataWindowController placeImage];
    
    [dataWindowController showWindow:self];
    
}

-(void) updateDataWindow{
    iBitmap = iBuffer;
    [dataWindowController updateImage];
    [dataWindowController showWindow:self];
    
    
    
}

-(void) eraseWindow:(int) n{
    if(dataWindowController){
        [[dataWindowController window ] close];
        [dataWindowController release];
        //NSLog(@"%ld",[dataWindowController retainCount]);
        //dataWindowController = nil;
        
        //[self->dataWindowController release];
        // NSLog(@"%ld",[dataWindowController retainCount]);
    }

}

-(void) dataWindowClosing{
    dataWindowController = nil;
}


@end
