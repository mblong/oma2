//
//  CommandThread.h
//  oma2
//
//  Created by Marshall B. Long on 11/21/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "oma2.h"
//#include "comdec.h"



@interface CommandThread : NSObject{
    char omaCommand[CHPERLN];
    int commandReturn;
}
//@property int commandReturn;

- (void)runCalculations;
- (void)stopCalculations;
- (void)doCommand: (NSString*) theCommand;

@end
