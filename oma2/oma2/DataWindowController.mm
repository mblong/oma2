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
@synthesize windowRect;
@synthesize hasRowPlot;
@synthesize hasColPlot;
@synthesize thePalette;
//@synthesize bitmap;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib{
    [[self window] setFrame:windowRect display:NO];   // display will happen later
    //NSLog(@"%f %f %f %f",windowRect.origin.x,windowRect.origin.y,
    //windowRect.size.width,windowRect.size.height);
}

- (void)dealloc
{
    // more needed here
    // NSLog(@"deallocate DataWindowController");
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
   
    int number = -1;
    int i=0;
    NSMutableArray*  theArray = [appController windowArray];
    for (id thewindowController in theArray){
        if( [thewindowController window] == [self window]) number=i;
        i++;
    }
    //NSLog(@"Data Window %d Closing",number);
    if (number != -1 && [theArray[number] hasRowPlot] != CLOSE_CLEANUP_DONE)
                         [appController eraseWindow:number];

    //NSWindowController *theWindowController = [[notification object] delegate];
    
    //[theWindowController release];
    
    //[self release];
    //[super dealloc];
    //[myArrayOfWindowControllers removeObject: theWindowController];
}

-(void) placeImage:(NSRect) theRect{
    windowRect = theRect;
    hasColPlot = -1;
    hasRowPlot = -1;
    
    [[self window] setTitle:windowName];
    [self setThePalette:iBitmap.getpalette()];
    
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                //initWithBitmapDataPlanes: iBitmap.getpixdatap()
                                initWithBitmapDataPlanes: nil
                                pixelsWide: iBitmap.getwidth() pixelsHigh: iBitmap.getheight()
                                bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace
                                bytesPerRow: 4*iBitmap.getwidth()  
                                bitsPerPixel: 32];
    
    memcpy([bitmap  bitmapData], iBitmap.getpixdata(), iBitmap.getheight()*iBitmap.getwidth()*4);
    //NSImage* im = [[NSImage alloc] initByReferencingFile:@"./Contents/Resources/curve.jpg"];

    NSImage* im = [[NSImage alloc] initWithSize:NSMakeSize(iBitmap.getwidth(), iBitmap.getheight())];
    [im addRepresentation:bitmap];
    
    /*
    NSData* tifdata = [im TIFFRepresentation];
    NSImageRep* tifrep = [NSBitmapImageRep imageRepWithData:tifdata];
    [im addRepresentation:tifrep];
    [im removeRepresentation:bitmap];
    */
    
    if ( ![im isValid] ) {
        NSLog(@"Invalid Image");
    }
    
    NSRect rect = NSMakeRect(0, 0, windowRect.size.width,windowRect.size.height-TITLEBAR_HEIGHT);
    [imageView setFrame:rect];
    [imageView setImageScaling:NSScaleToFit];
    [imageView setImage:im];
    [imageView setRowLine: -1];
    [imageView setColLine: -1];
    [imageView setRowWindowController: NULL];
    
    //[imageView setNeedsDisplay:YES]; // for display in macro, this doesn't do the job
    [imageView display];
    
}


-(void) updateImage{
    // this is called when redisplaying the current image from events in the status window
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes: nil
                                pixelsWide: iBitmap.getwidth() pixelsHigh: iBitmap.getheight()
                                bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace
                                bytesPerRow: 4*iBitmap.getwidth()  
                                bitsPerPixel: 32];
    
    memcpy([bitmap  bitmapData], iBitmap.getpixdata(), iBitmap.getheight()*iBitmap.getwidth()*4);
    //bitmap = [bitmap  bitmapImageRepByRetaggingWithColorSpace:[NSColorSpace genericRGBColorSpace]];
    
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    
    NSRect rect = NSMakeRect(0, 0, windowRect.size.width,windowRect.size.height-TITLEBAR_HEIGHT);
    [imageView setFrame:rect];
    [imageView setImageScaling:NSScaleToFit];
    [imageView setImage:im];

    [imageView display];
}


-(void) placeRowLine: (int) theRow{
    [imageView setRowLine:theRow];
    [imageView display];
}

-(void) placeColLine: (int) theCol{
    [imageView setColLine:theCol];
    [imageView display];
}


-(BOOL) acceptsFirstResponder{
    return NO;
}

- (void)keyDown:(NSEvent *)anEvent{
    [[appController theWindow] sendEvent: anEvent];
}



- (IBAction)copy:sender {
    
    // this copies the image and any other stuff written on it
    // it also looses the alpha channel
    NSImageView *view = [self imageView];
    NSRect r = [view bounds];
    if (view != nil) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [view writePDFInsideRect:r toPasteboard: pasteboard];
    }
    
    
    /*
    // If you wanted to include the alpha channel, you would need to add the image to the clipboard explicitly like this
    NSImage *image = [imageView image];
    if (image != nil) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        NSArray *copiedObjects = @[image];
        [pasteboard writeObjects:copiedObjects];
    }
    */
    
}



@end
