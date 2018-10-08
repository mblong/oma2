
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

- (id)initWithFrame:(NSRect)frame       // this never gets called
{
    self = [super initWithFrame:frame];
    if (self) {
        // three ways found on the internet to set tabs -- maybe all work; I just implemented the last one
        //first one
        /*
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setDefaultTabInterval:36.];
        [style setTabStops:[NSArray array]];
        [self setDefaultParagraphStyle:style];
        [self setTypingAttributes:[NSDictionary dictionaryWithObject:style forKey:style]];
        */
        // second one
        /*
        int cnt;
        int numStops = 20;
        int tabInterval = 40;
        NSTextTab *tabStop;
        
        NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];
        //attributes for attributed String of TextView
        
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        
        // This first clears all tab stops, then adds tab stops, at desired intervals...
        [paraStyle setTabStops:[NSArray array]];
        for (cnt = 1; cnt <= numStops; cnt++) {
            tabStop = [[NSTextTab alloc] initWithType:NSLeftTabStopType location: tabInterval * (cnt)];
            [paraStyle addTabStop:tabStop];
        }
        
        [attrs setObject:paraStyle forKey:NSParagraphStyleAttributeName];
        
        [[self textStorage] addAttributes:attrs range:NSMakeRange(0, [[[self textStorage] string] length])];
         */
        // Initialization code here.
    }
    return self;
}

-(void) initTabs {
    [[self textStorage] setAttributedString:[self textViewTabFormatter:@"O"]];
    lastReturn = 1;
}

-(NSMutableAttributedString *) textViewTabFormatter:(NSString *)aString
{
    float columnWidthInInches = .4f;
    float pointsPerInch = 72.0f;
    
    NSMutableArray * tabArray = [NSMutableArray arrayWithCapacity:25];
    
    for(NSInteger tabCounter = 0; tabCounter < 25; tabCounter++)
    {
        NSTextTab * aTab = [[NSTextTab alloc] initWithType:NSLeftTabStopType location:(tabCounter * columnWidthInInches * pointsPerInch)];
        [tabArray addObject:aTab];
    }
    
    NSMutableParagraphStyle * aMutableParagraphStyle = [[NSParagraphStyle defaultParagraphStyle]mutableCopy];
    [aMutableParagraphStyle setTabStops:tabArray];
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:aString];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:aMutableParagraphStyle range:NSMakeRange(0,[aString length])];
    
    return attributedString;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

// this normally does text completions -- over riding this gets rid of cmnd . listing of words
// somehow still doesn't work to stop macros
- (void)complete:(id)sender{
    extern int stopMacroNow;
    NSLog(@"Stop Macro");
    stopMacroNow = 1;
}

- (void)keyDown:(NSEvent *)anEvent{
    
    // we get keydown events here
    // do special processing before passing this event along the the NSTextView
    extern int stopMacroNow,pause_flag;
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
    
    if(pause_flag == 1){
        pause_flag = 0;
        dispatch_queue_t queue = dispatch_queue_create("oma.oma2.CommandTask",NULL);
        
        dispatch_async(queue,^{
            int returnValue = comdec((char*) oma2Command);
            if(returnValue < GET_MACRO_LINE) printf("OMA2>");
        });
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
        } else if( keyChar == NSDownArrowFunctionKey){
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
        } else if(keyChar == NSDeleteCharacter) { // don't delete beyond last prompt
            
            if (self.textStorage.mutableString.length <= lastReturn) {
                return;
            }
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
        
        char* cmd = (char*) [command cStringUsingEncoding:NSUTF8StringEncoding ];
        if(cmd == NULL || strlen(cmd) <=0) return; // if for some reason this can't be translated, just give up
        // replace the \n with an EOL
        cmd[strlen(cmd)-1] = 0;
        strlcpy(oma2Command, cmd, CHPERLN);
        
        // these two seem to behave the same way
        
        //dispatch_queue_t queue = dispatch_get_global_queue(0,0);
        dispatch_queue_t queue = dispatch_queue_create("oma.oma2.CommandTask",NULL);
        
        dispatch_async(queue,^{
            int returnValue = comdec((char*) oma2Command);
            if(returnValue < GET_MACRO_LINE) printf("OMA2>");
        });

    }
}

-(void) appendText:(NSString *) string{
    lastReturn += [string length];
    //[[[theCommands textStorage] mutableString] appendString: string];
    [self.textStorage.mutableString appendString:string];
    [self scrollRangeToVisible: NSMakeRange(self.string.length, 0)];
}

-(void) appendCText:(char *) string{
    extern int isErrorText;
    NSString *reply = [[NSString alloc] initWithCString:string encoding:NSASCIIStringEncoding];
    
    [self.textStorage.mutableString appendString:reply ];
    if (isErrorText) {
        [self setTextColor:[NSColor redColor] range:
         NSMakeRange(lastReturn, self.textStorage.mutableString.length - lastReturn)];
        isErrorText = 0;
    }else{
        [self setTextColor:[NSColor textColor] range:
         NSMakeRange(lastReturn, self.textStorage.mutableString.length - lastReturn)];
    }
    lastReturn += [reply length];
    
    [self scrollRangeToVisible: NSMakeRange(self.string.length, 0)];
    
}

-(BOOL) acceptsFirstResponder{
    return YES;
}


@end
