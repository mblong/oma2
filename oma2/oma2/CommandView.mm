//
//  CommandView.m
//  oma2
//
//  Created by Marshall Long on 11/3/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import "CommandView.h"
#import "AppController.h"
#import "ImageBitmap.h"
//#import "image.h"



extern AppController* appController;

@implementation CommandView

@synthesize lastReturn;
@synthesize commandThread;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

// this does text completions -- over riding this gets rid of cmnd . listing of words
- (void)complete:(id)sender{
    
}

- (void)keyDown:(NSEvent *)anEvent{
    extern int stopMacroNow;
    // we get keydown events here
    // do special processing before passing this event along the the NSTextView
    
    if (commandThread == NULL) {
        [self setCommandThread:[[CommandThread alloc] init]] ;
    }

    
    // move to the end of the commands
    NSUInteger text_len = [[[self textStorage] string] length];
    [self setSelectedRange:(NSRange){text_len, 0}];
    
    if([anEvent modifierFlags] & NSCommandKeyMask){
        NSString *theKey = [anEvent charactersIgnoringModifiers];
        if([theKey isEqualToString:@";"]){
            NSLog(@"Stop Macro");
            stopMacroNow = 1;
            //stopmacro();
            
        }
        return;
    }
    
    // up arrow and down arrow 
    NSString *theKey = [anEvent charactersIgnoringModifiers];
    //NSString *theKey = [anEvent characters];
    unichar keyChar = 0;
    if ( [theKey length] == 0 )
        return;            // reject dead keys
    if ( [theKey length] == 1 ) {
        keyChar = [theKey characterAtIndex:0];
        //NSLog(@"upArrow");
        extern char cmnd_history[];
        extern int hist_index;
        extern int selected_hist_index;
        //extern int stored_commands;
        char gets_string[CHPERLN];

        if ( keyChar == NSUpArrowFunctionKey ) {
            
            if(selected_hist_index > 0) {
                selected_hist_index-=2;
                while(selected_hist_index >= 0 && cmnd_history[selected_hist_index] !=0) {
                    selected_hist_index--;
                }
                selected_hist_index++;
                
                strcpy(gets_string,&cmnd_history[selected_hist_index]);
                
                NSString *text  = [[self textStorage] string];
                
                if (lastReturn == [text length] ) {
                    // we are at the end of the text -- just add the last command
                    [[[self textStorage] mutableString] appendString: [[NSString alloc] initWithCString:gets_string encoding:NSASCIIStringEncoding]];
                    
                    
                } else {
                    // need to get rid of the last bit that hasn't been treated as a command
                    //NSLog(@"clean text");
                    NSRange theRange = NSMakeRange(lastReturn, self.textStorage.mutableString.length - lastReturn);
                    [self.textStorage.mutableString  deleteCharactersInRange:theRange];
                    // then add the text
                    [[[self textStorage] mutableString] appendString: [[NSString alloc] initWithCString:gets_string encoding:NSASCIIStringEncoding]];
                }
                [self setNeedsDisplay:YES];
                
            }
            return;
        }
        else if( keyChar == NSDownArrowFunctionKey){
            if(selected_hist_index < hist_index) {
                
                while(cmnd_history[selected_hist_index] !=0) {
                    selected_hist_index++;
                }
                selected_hist_index++;
                if(selected_hist_index < hist_index){
                    
                    strcpy(gets_string,&cmnd_history[selected_hist_index]);
                    //NSString *text  = [[self textStorage] string];
                    // need to get rid of the last bit that hasn't been treated as a command
                    NSRange theRange = NSMakeRange(lastReturn, self.textStorage.mutableString.length - lastReturn);
                    [self.textStorage.mutableString  deleteCharactersInRange:theRange];
                    // then add the text
                    [[[self textStorage] mutableString] appendString: [[NSString alloc] initWithCString:gets_string encoding:NSASCIIStringEncoding]];

                    [self setNeedsDisplay:YES];
                }
            }
            return;
        }
    }
    [super keyDown:anEvent];
}

-(void) textDidChange:(NSNotification *) pNotify {
    
    NSString *text  = [[self textStorage] string];
    NSString *ch = [text substringFromIndex:[text length] - 1];
    
    if([ch isEqualToString:@"\n"]){
        NSString *command = [text substringFromIndex:lastReturn];
        lastReturn = [text length];
        // pass this to the command decoder
        
        char* cmd = (char*) [command cStringUsingEncoding:NSASCIIStringEncoding];
        // replace the \n with an EOL
        cmd[strlen(cmd)-1] = 0;
        strlcpy(oma2Command, cmd, CHPERLN);
        
        // these two seem to behave the same way
        
        //dispatch_queue_t queue = dispatch_get_global_queue(0,0);
        dispatch_queue_t queue = dispatch_queue_create("oma.oma2.CommandTask",NULL);
        
        dispatch_async(queue,^{comdec((char*) oma2Command);});

        
        //int returnVal = comdec((char*) oma2Command);
        /*
        extern int exflag, macflag;
        int didMac = 0;
        while (exflag || macflag) {
            returnVal = [self scheduleCommand:command];
            //returnVal = comdec((char*) oma2Command);
            didMac = 1;
        }
        if (didMac) {
            [[appController theWindow ] makeKeyAndOrderFront:[appController theWindow]];
        }
        */
        
        //int returnVal = [self scheduleCommand:command];
        
        /*
        if (returnVal < GET_MACRO_LINE ) {
            [self appendText: @"OMA2>"];
        }
        */
    }
}

/*
- (int)scheduleCommand: (NSString*) theCommand{
    int result=NO_ERR;
    
    [NSThread detachNewThreadSelector:@selector (doCommand:)
                             toTarget:commandThread
                           withObject:theCommand]; // Or you can send an object if you need to

    return result;
}
*/


-(void) appendText:(NSString *) string{
    lastReturn += [string length];
    //[[[theCommands textStorage] mutableString] appendString: string];
    [self.textStorage.mutableString appendString:string];
    [self scrollRangeToVisible: NSMakeRange(self.string.length, 0)];
}

-(void) appendCText:(char *) string{
    NSString *reply = [[NSString alloc] initWithCString:string encoding:NSASCIIStringEncoding];
    lastReturn += [reply length];
    [self.textStorage.mutableString appendString:reply];
    [self scrollRangeToVisible: NSMakeRange(self.string.length, 0)];
    
}

-(BOOL) acceptsFirstResponder{
    return YES;
}


@end
