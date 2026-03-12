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

// Helper function to create NSBitmapImageRep from ImageBitmap,
// using 16-bit extended sRGB for HDR color images or standard 8-bit otherwise.
NSBitmapImageRep* createBitmapRep(ImageBitmap& bitmap) {
    if (bitmap.isHDR() && bitmap.getpixdata16() != NULL) {
        // 16-bit HDR path for color images
        NSBitmapImageRep* rep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes: nil
            pixelsWide: bitmap.getwidth()
            pixelsHigh: bitmap.getheight()
            bitsPerSample: 16
            samplesPerPixel: 3
            hasAlpha: NO
            isPlanar: NO
            colorSpaceName: NSCalibratedRGBColorSpace
            bitmapFormat: NSBitmapFormatSixteenBitLittleEndian
            bytesPerRow: 6 * bitmap.getwidth()
            bitsPerPixel: 48];
        
        memcpy([rep bitmapData], bitmap.getpixdata16(),
               bitmap.getheight() * bitmap.getwidth() * 3 * sizeof(unsigned short));
        
        // Retag with extended sRGB to allow values representing brightness > 1.0
        rep = [rep bitmapImageRepByRetaggingWithColorSpace:
               [NSColorSpace extendedSRGBColorSpace]];
        
        return rep;
    } else {
        // Standard 8-bit SDR path
        NSBitmapImageRep* rep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes: nil
            pixelsWide: bitmap.getwidth()
            pixelsHigh: bitmap.getheight()
            bitsPerSample: 8
            samplesPerPixel: 3
            hasAlpha: NO
            isPlanar: NO
            colorSpaceName: NSDeviceRGBColorSpace
            bytesPerRow: 3 * bitmap.getwidth()
            bitsPerPixel: 24];
        
        memcpy([rep bitmapData], bitmap.getpixdata(),
               bitmap.getheight() * bitmap.getwidth() * 3);
        
        return rep;
    }
}

@implementation DataWindowController

@synthesize  windowName;
@synthesize imageView;
@synthesize windowRect;
@synthesize hasRowPlot;
@synthesize hasColPlot;
@synthesize thePalette;
@synthesize dataRows;
@synthesize dataCols;
@synthesize intensity;
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
    delete intensity;
    [appController dataWindowClosing];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [imageView setDegrees:0];
    [imageView setZoom:1.0];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

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
    
    NSBitmapImageRep* bitmap = createBitmapRep(iBitmap);
    
    intensitySize = iBitmap.getheight()*iBitmap.getwidth();
    dataCols = iBitmap.getwidth();
    dataRows = iBitmap.getheight();
    if (iBitmap.getpalette() == -1) intensitySize *= 3;
    intensity = new unsigned char[intensitySize];
    memcpy(intensity,iBitmap.getintensitydata(),intensitySize);
    
    //NSImage* im = [[NSImage alloc] initByReferencingFile:@"./Contents/Resources/curve.jpg"];

    NSImage* im = [[NSImage alloc] initWithSize:NSMakeSize(iBitmap.getwidth(), iBitmap.getheight())];
    [im addRepresentation:bitmap];
    
    //[im compositeToPoint:NSZeroPoint operation:NSCompositeDestinationOver];
    //[im drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationDestinationOver fraction:1];
    
    /*
    NSData* tifdata = [im TIFFRepresentation];
    NSImageRep* tifrep = [NSBitmapImageRep imageRepWithData:tifdata];
    [im addRepresentation:tifrep];
    [im removeRepresentation:bitmap];
    */
    
    if ( ![im isValid] ) {
        //NSLog(@"Invalid Image");
    }
    
    //NSRect rect = NSMakeRect(0, 0, windowRect.size.width,windowRect.size.height-TITLEBAR_HEIGHT);
    //NSRect newRect = self.window.contentView.visibleRect;
    //[imageView setFrame:rect];
    if (@available(macOS 14.0, *)) {
        if (iBitmap.isHDR()) {
            [imageView setPreferredImageDynamicRange:NSImageDynamicRangeHigh];
        } else {
            [imageView setPreferredImageDynamicRange:NSImageDynamicRangeStandard];
        }
    }
    [imageView setImageScaling:NSImageScaleAxesIndependently];
    [imageView setImage:im];
    [imageView setRowLine: -1];
    [imageView setColLine: -1];
    [imageView setRowWindowController: NULL];
    
    [imageView setSelectedIndex: -1];
    
    //[imageView setNeedsDisplay:YES]; // for display in macro, this doesn't do the job
    [imageView display];
    
}


-(void) updateImage{
    // this is called when redisplaying the current image from events in the status window
    
    NSBitmapImageRep* bitmap = createBitmapRep(iBitmap);
    
    int newintensitySize = iBitmap.getheight()*iBitmap.getwidth();
    dataCols = iBitmap.getwidth();
    dataRows = iBitmap.getheight();

    if (iBitmap.getpalette() == -1) newintensitySize *= 3;
    if(intensitySize != newintensitySize){
        intensitySize = newintensitySize;
        delete intensity;
        intensity = new unsigned char[intensitySize];
    }
    memcpy(intensity,iBitmap.getintensitydata(),intensitySize);
    
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    
    
    //NSRect rect = NSMakeRect(0, 0, windowRect.size.width,windowRect.size.height-TITLEBAR_HEIGHT); // works but cumbersome
    //[im drawAtPoint:NSZeroPoint fromRect:rect operation:NSCompositingOperationDestinationOver fraction:1]; // not needed
    //[imageView setFrame:rect];
    //[imageView setFrame:self.window.contentView.visibleRect];     // wrong
    [imageView setFrame:self.window.contentLayoutRect];
    
    if (@available(macOS 14.0, *)) {
        if (iBitmap.isHDR()) {
            [imageView setPreferredImageDynamicRange:NSImageDynamicRangeHigh];
        } else {
            [imageView setPreferredImageDynamicRange:NSImageDynamicRangeStandard];
        }
    }
    [imageView setImageScaling:NSImageScaleAxesIndependently];
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
#ifdef ZWO
    extern int stopExposure;
    if([anEvent modifierFlags] & NSEventModifierFlagCommand){
        NSString *theKey = [anEvent charactersIgnoringModifiers];
        if([theKey isEqualToString:@"'"]){
            stopExposure=1;
            return;
        }
    }
#endif
    [[appController theWindow] sendEvent: anEvent];
}

-(int) saveToPdf: (char*) fileName{
    NSImageView *view = [self imageView];
    NSRect r = [view bounds];
    if (view != nil) {
        NSData *data;
        data = [view dataWithPDFInsideRect:r];
        NSString *theFile = [NSString stringWithCString:fileName encoding:NSASCIIStringEncoding];
        return [data writeToFile: theFile atomically: NO];
    }    
    return FILE_ERR;
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
