//
//  DataWindowController.m
//  oma2
//
//  Created by Marshall Long on 3/29/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "DataWindowController.h"
#import "AppController.h"
#import "ImageBitmap.h"

extern ImageBitmap iBitmap;
extern AppController* appController; 

@implementation DataWindowController

@synthesize  windowName;
@synthesize imageView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.

    }
    
    return self;
}

-(void)awakeFromNib{
    
}

- (void)dealloc
{
    [super dealloc];
    NSLog(@"deallocate DataWindowController");
    [appController dataWindowClosing];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    //[[self window] setTitle:windowName];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSRect rect=NSMakeRect(100, 100, iBitmap.getwidth(), iBitmap.getheight()+20);
    [[self window] setTitle:windowName];
    [[self window] setFrame:rect display:YES];

    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes: iBitmap.getpixdatap() 
                                pixelsWide: iBitmap.getwidth() pixelsHigh: iBitmap.getheight()
                                bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar:NO
                                colorSpaceName:NSCalibratedRGBColorSpace 
                                bytesPerRow: 4*iBitmap.getwidth()  
                                bitsPerPixel: 32];
    
    NSImage *im = [[[NSImage alloc] init] autorelease];
    [im addRepresentation:bitmap];
    if ( ![im isValid] ) {
        NSLog(@"Invalid Image");
    }
    [imageView setFrameOrigin:NSMakePoint(0,0)];
    [imageView setFrameSize:NSMakeSize(iBitmap.getwidth(), iBitmap.getheight())];

    //NSRect rect=NSMakeRect(0, 0, 500, 500);
    //imageView = [[NSImageView alloc] initWithFrame:rect];
    //[imageView setImageScaling:NSScaleToFit];
    
    [imageView setImage:im];
    //[imageView setImage:[NSImage imageNamed:@"bike.jpg"]];
    

    
    [imageView display];

}


- (void) windowWillClose:(NSNotification *) notification
{
    NSWindowController *theWindowController = [[notification object] delegate];
    
    [theWindowController release];
    
    //[self release];
    //[super dealloc]
    //[myArrayOfWindowControllers removeObject: theWindowController];
}

-(void) placeImage{
    

    /*
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes: iBitmap.getpixdatap() pixelsWide: iBitmap.getwidth() pixelsHigh: iBitmap.getheight()bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace bytesPerRow: 0  
                                bitsPerPixel: 32];
    
    NSImage *im = [[[NSImage alloc] init] autorelease];
    [im addRepresentation:bitmap];
    NSRect rect=NSMakeRect(10, 10, 400, 300);
    imageView = [[NSImageView alloc] initWithFrame:rect];
    [imageView setImageScaling:NSScaleToFit];
    
    //[imageView setImage:im];
    [imageView setImage:[NSImage imageNamed:@"bike.jpg"]];
    [imageView setNeedsDisplay];
    */
    //[self addSubview:imageView];

}

-(BOOL) acceptsFirstResponder{
    return YES;
}

- (void)keyDown:(NSEvent *)anEvent{
    [[appController theWindow] sendEvent: anEvent];
}


@end
