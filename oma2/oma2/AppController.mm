//
//  AppController.m
//  oma2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "AppController.h"
#import "PreferenceController.h"

AppController   *appController;

@implementation AppController

@synthesize theCommands;



- (IBAction)showPrefs:(id)sender{
    if(!preferenceController){
        preferenceController = [[PreferenceController alloc] initWithWindowNibName:@"Preferences"];
    }
    [preferenceController showWindow:self];
    
}


-(void)awakeFromNib{
    appController = [self whoami];
    [self appendText: @"OMA2>"];
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
        comdec((char*) cmd);
        [self appendText: @"OMA2>"];
    }
}




@end
