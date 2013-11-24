//
//  CommandThread.m
//  oma2
//
//  Created by Marshall B. Long on 11/21/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import "CommandThread.h"
#import "AppController.h"
//#import "ImageBitmap.h"


@implementation CommandThread

//@synthesize commandReturn;

- (void)runCalculations
{
    //continueCalc = 1;
    //doCalc(10);
    //NSLog(@"Done");
}

- (void) stopCalculations
{
    //continueCalc = 0;
}

- (void)doCommand: (NSString*) theCommand{
    int comdec(char*);    
    char* cmd = (char*) [theCommand cStringUsingEncoding:NSASCIIStringEncoding];
    // replace the \n with an EOL
    if (strlen(cmd)>0) cmd[strlen(cmd)-1] = 0;
    strlcpy(omaCommand, cmd, CHPERLN);
    commandReturn = comdec(omaCommand);
}


@end
