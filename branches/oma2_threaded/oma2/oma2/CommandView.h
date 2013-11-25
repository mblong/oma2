//
//  CommandView.h
//  oma2
//
//  Created by Marshall Long on 11/3/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "oma2.h"
#import "CommandThread.h"

@class CommandThread;

@interface CommandView : NSTextView{
    char oma2Command[CHPERLN];
}

@property NSUInteger lastReturn;
@property CommandThread   *commandThread;

-(void) appendText:(NSString *) string;
-(void) appendCText:(char *) string;
-(void) textDidChange:(NSNotification *) pNotify;


@end
