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
#import "DataView.h"

extern ImageBitmap iBitmap;
extern Image iBuffer;
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
    NSScreen *mainScreen = [NSScreen mainScreen];
    NSRect screenRect = [mainScreen visibleFrame];
    
    // resize here before display
    NSRect rect=NSMakeRect(screenRect.origin.x, screenRect.size.height, iBitmap.getwidth(), iBitmap.getheight()+22);
    [[self window] setFrame:rect display:NO];   // display will happen later
}

- (void)dealloc
{
    // more needed here
    NSLog(@"deallocate DataWindowController");
    //[bitmap release];
    //[imageView release];          // this crashes things eventually
    [appController dataWindowClosing];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    //[[self window] setTitle:windowName];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
/*    
    [[self window] setTitle:windowName];

    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes: iBitmap.getpixdatap() 
                                pixelsWide: iBitmap.getwidth() pixelsHigh: iBitmap.getheight()
                                bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar:NO
                                colorSpaceName:NSCalibratedRGBColorSpace 
                                bytesPerRow: 4*iBitmap.getwidth()  
                                bitsPerPixel: 32];
    
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    if ( ![im isValid] ) {
        NSLog(@"Invalid Image");
    }

    
    [imageView setImage:im];
    [imageView setImageScaling:NSImageScaleAxesIndependently];
    [imageView setNeedsDisplay:YES];
*/    

}


- (void) windowWillClose:(NSNotification *) notification
{
    //NSWindowController *theWindowController = [[notification object] delegate];
    
    //[theWindowController release];
    
    //[self release];
    //[super dealloc]
    //[myArrayOfWindowControllers removeObject: theWindowController];
}

-(void) placeImage{
    [[self window] setTitle:windowName];
    
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes: iBitmap.getpixdatap() 
                                pixelsWide: iBitmap.getwidth() pixelsHigh: iBitmap.getheight()
                                bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar:NO
                                colorSpaceName:NSCalibratedRGBColorSpace 
                                bytesPerRow: 4*iBitmap.getwidth()  
                                bitsPerPixel: 32];
    
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    if ( ![im isValid] ) {
        NSLog(@"Invalid Image");
    }
    
    
    [imageView setImage:im];
    [imageView setImageScaling:NSImageScaleAxesIndependently];
    [imageView setNeedsDisplay:YES];

}

-(void) updateImage{
    
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes: iBitmap.getpixdatap() 
                                pixelsWide: iBitmap.getwidth() pixelsHigh: iBitmap.getheight()
                                bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar:NO
                                colorSpaceName:NSCalibratedRGBColorSpace 
                                bytesPerRow: 4*iBitmap.getwidth()  
                                bitsPerPixel: 32];
    
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    if ( ![im isValid] ) {
        NSLog(@"Invalid Image");
    }
    
    [imageView setImage:im];
    [imageView setImageScaling:NSImageScaleAxesIndependently];
    [imageView display];

}

-(BOOL) acceptsFirstResponder{
    return YES;
}

- (void)keyDown:(NSEvent *)anEvent{
    [[appController theWindow] sendEvent: anEvent];
}



@end
