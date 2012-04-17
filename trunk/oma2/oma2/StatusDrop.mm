//
//  StatusDrag.m
//  oma2
//
//  Created by Marshall Long on 4/17/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "StatusDrop.h"

@implementation StatusDrop

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    /*if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
        [sender draggingSourceOperationMask] & NSDragOperationCopy) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;*/  
    return NSDragOperationCopy;     // respond to all here too
}


- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        //NSLog(@"%@",[fileURL path]);
        NSString *ext = [fileURL pathExtension] ;
        NSString *name = [fileURL path] ;
        const char* cname = [name cStringUsingEncoding:NSASCIIStringEncoding];
        const char* cext = [ext cStringUsingEncoding:NSASCIIStringEncoding];
        dropped_file((char*)cext,(char*)cname);
        [ext release];
        [name release];
        //delete []cname;
        //delete []cext;
        // Perform operation using the file’s URL
    }
    return YES;}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    //[self setNeedsDisplay:YES];
}


@end
