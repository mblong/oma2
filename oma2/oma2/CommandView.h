//
//  CommandView.h
//  oma2
//
//  Created by Marshall Long on 11/3/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CommandView : NSTextView

@property NSUInteger lastReturn;

-(void) appendText:(NSString *) string;
-(void) appendCText:(char *) string;
-(void) textDidChange:(NSNotification *) pNotify;
@end
