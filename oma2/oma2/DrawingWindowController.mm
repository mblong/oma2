//
//  DrawingWindowController.m
//  oma2
//
//  Created by Marshall Long on 10/6/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import "DrawingWindowController.h"
#import "DrawingView.h"
#import "AppController.h"
#import "ImageBitmap.h"
#import "DataView.h"

extern ImageBitmap iBitmap;
extern Image iBuffer;
extern AppController* appController;

/*
@interface DrawingWindowController ()

@end
*/


@implementation DrawingWindowController

@synthesize windowName;
@synthesize drawingView;
@synthesize windowRect;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)awakeFromNib{
    [[self window] setFrame:windowRect display:NO];   // display will happen later
    //NSLog(@"%f %f %f %f",windowRect.origin.x,windowRect.origin.y,
    //windowRect.size.width,windowRect.size.height);
}

- (void)dealloc
{
    // more needed here
    NSLog(@"deallocate DataWindowController");
    //[bitmap release];
    //[imageView release];          // this crashes things eventually
    
    // NEED TO IMPLEMENT THIS
    //[appController dataWindowClosing];
}


- (void) windowWillClose:(NSNotification *) notification
{
    //NSWindowController *theWindowController = [[notification object] delegate];
    
    //[theWindowController release];
    
    //[self release];
    //[super dealloc]
    //[myArrayOfWindowControllers removeObject: theWindowController];
}

-(void) placeDrawing: (NSRect) theLocation fromRect:(NSRect) dataRect{
    
    NSBitmapImageRep* imageRep=[[NSBitmapImageRep alloc] initWithFocusedViewRect: dataRect] ;
    unsigned char* bytes = [imageRep bitmapData];
    int bitsPerPixel  = [imageRep bitsPerPixel];
    int bytesPerRow = [imageRep bytesPerRow];
    
    windowRect = theLocation;
    
    [[self window] setTitle:windowName];
    
    
    NSRect rect = NSMakeRect(0, 0, windowRect.size.width,windowRect.size.height-TITLEBAR_HEIGHT);
    [drawingView setFrame:rect];
    
    [drawingView display];
    
    
    
}


-(BOOL) acceptsFirstResponder{
    return YES;
}

- (void)keyDown:(NSEvent *)anEvent{
    [[appController theWindow] sendEvent: anEvent];
}
/*
- (IBAction)copy:sender {
    NSImage *image = [imageView image];
    if (image != nil) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        NSArray *copiedObjects = [NSArray arrayWithObject:image];
        [pasteboard writeObjects:copiedObjects];
    }
}
*/

@end
