//
//  CommandView.h
//  oma2
//
//  Created by Marshall Long on 11/3/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "oma2.h"


@interface CommandView : NSTextView{
    char oma2Command[CHPERLN];
}

@property NSUInteger lastReturn;

-(void) appendText:(NSString *) string;
-(void) appendCText:(char *) string;
-(void) textDidChange:(NSNotification *) pNotify;
-(void) initTabs;

@end
