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
#import "DataWindowController.h"

extern ImageBitmap iBitmap;
extern Image iBuffer;
extern AppController* appController;

/*
@interface DrawingWindowController ()

@end
*/


@implementation DrawingWindowController

//@synthesize window;
@synthesize windowName;
@synthesize drawingView;
@synthesize windowRect;
@synthesize dataWindowController;
@synthesize drawingType;

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
    int number = -1;
    int i=0;
    NSMutableArray*  theArray = [appController windowArray];
    for (id thewindowController in theArray){
        if( [thewindowController window] == [self window]) number=i;
        i++;
    }
    //NSLog(@"Drawing Window %d Closing",number);
    if (number != -1 && [theArray[number] drawingType] != CLOSE_CLEANUP_DONE)
        [appController eraseWindow:number];

}

-(void) placeRowDrawing: (NSRect) theLocation {
    extern RGBColor color[256][8];
    drawingType = ROW_DRAWING;
    
    [[dataWindowController imageView] setEraseLines:1];
    [[dataWindowController imageView] display];

    // where the data comes from
    NSRect dataRect =  [[dataWindowController imageView] frame ];
    
    // change the dataRect to be a single row
    int theRow = dataRect.size.height/2;       // start in the middle
    dataRect.origin.y = theRow;
    dataRect.size.height = 1;
    
    // get the bitmap from the data window
    [[dataWindowController imageView] lockFocus];
    NSBitmapImageRep* imageRep=[[NSBitmapImageRep alloc] initWithFocusedViewRect: dataRect] ;
    
    //imageRep = [imageRep bitmapImageRepByRetaggingWithColorSpace:[NSColorSpace sRGBColorSpace]];
    
    NSData* rowData = [[NSData alloc] initWithBytes:[imageRep bitmapData] length:[imageRep bytesPerRow]];
    unsigned char* bytes = [imageRep bitmapData];
    int bytesPerRow = (int)[imageRep bytesPerRow];
    
    //int pixPerPt = bytesPerRow/4/[[dataWindowController imageView] frame ].size.width;  // for retina displays
    [[dataWindowController imageView] unlockFocus];
    
    [dataWindowController setHasRowPlot:theRow];
    [dataWindowController placeRowLine:theRow];
    [[dataWindowController imageView] setRowWindowController:self];
    int pal = [dataWindowController thePalette];
    int j;
    unsigned char r,g,b,rr,gg,bb;
    if(pal >= 0){
        
        // we have a monochrome image, decode
        for (int i=0; i < bytesPerRow; i+=4) {
            
            for( j=0; j < 256; j++){
                r = color[j][pal].red;
                g = color[j][pal].green;
                b = color[j][pal].blue;
                rr = *(bytes+i);
                gg = *(bytes+i+1);
                bb = *(bytes+i+2);
                if (rr == r &&
                    gg == g &&
                    bb == b) {
                    break;
                }
            }
            // have the palette index
            *(bytes+i) = *(bytes+i+1) = *(bytes+i+2) = j;
        }
    }
    
    windowRect = theLocation;
    [[self window] setTitle:windowName];
    
    NSRect rect = NSMakeRect(0, 0, windowRect.size.width,windowRect.size.height-TITLEBAR_HEIGHT);
    [drawingView setFrame:rect];
    
    //[drawingView setRowData: bytes + theRow*bytesPerRow*pixPerPt];
    [drawingView setRowData: rowData];
    [drawingView setBytesPerRow: bytesPerRow];
    [drawingView setPixPerPt: bytesPerRow/4/[[dataWindowController imageView] frame ].size.width];
    
    [drawingView display];
    [[dataWindowController imageView] setEraseLines:0];
    [[dataWindowController imageView] display];

}

-(void) updateRowDrawing: (int) theRow {
    // where the data comes from
    NSRect dataRect =  [[dataWindowController imageView] frame ];
    // change the dataRect to be a single row
    dataRect.origin.y = dataRect.size.height - theRow-1;
    dataRect.size.height = 1;
    
    [[dataWindowController imageView] setEraseLines:1];
    [[dataWindowController imageView] display];


    // get the bitmap from the data window
    [[dataWindowController imageView] lockFocus];
    NSBitmapImageRep* imageRep=[[NSBitmapImageRep alloc] initWithFocusedViewRect: dataRect] ;
    
    //imageRep = [imageRep bitmapImageRepByRetaggingWithColorSpace:[NSColorSpace sRGBColorSpace]];
    
    //unsigned char* bytes = [imageRep bitmapData];
    int bytesPerRow = (int)[imageRep bytesPerRow];
    NSData* rowData = [[NSData alloc] initWithBytes:[imageRep bitmapData] length:[imageRep bytesPerRow]];
    //int pixPerPt = bytesPerRow/4/[[dataWindowController imageView] frame ].size.width;  // for retina displays
    [[dataWindowController imageView] unlockFocus];
    
    
    //[drawingView setRowData: bytes + theRow*bytesPerRow*pixPerPt];
    [drawingView setRowData: rowData];
    [drawingView setBytesPerRow: bytesPerRow];
    
    [drawingView display];
    [[dataWindowController imageView] setEraseLines:0];
    [[dataWindowController imageView] display];
}

-(void) placeColDrawing: (NSRect) theLocation {
    drawingType = COL_DRAWING;
    
    [[dataWindowController imageView] setEraseLines:1];
    [[dataWindowController imageView] display];

    // where the data comes from
    NSRect dataRect =  [[dataWindowController imageView] frame ];
    int theCol = dataRect.size.width/2;       // start in the middle
    // get the bitmap from the data window
    [[dataWindowController imageView] lockFocus];
    NSBitmapImageRep* imageRep=[[NSBitmapImageRep alloc] initWithFocusedViewRect: dataRect] ;
    unsigned char* bytes = [imageRep bitmapData];
    int bytesPerRow = (int)[imageRep bytesPerRow];
    
    int pixPerPt = bytesPerRow/4/[[dataWindowController imageView] frame ].size.width;
    
    unsigned char* colbytes = new unsigned char[(int)dataRect.size.height*pixPerPt*4];
    int n=0;
    for(int i=0; i < (int)dataRect.size.height*pixPerPt; i++){
        for(int j=0; j < 4; j++){
            colbytes[n++] = *(bytes+i*bytesPerRow+theCol*4*pixPerPt+j);
        }
    }
    
    [[dataWindowController imageView] unlockFocus];
    
    [dataWindowController setHasColPlot:theCol];
    [dataWindowController placeColLine:theCol];
    [[dataWindowController imageView] setColWindowController:self];
    
    windowRect = theLocation;
    [[self window] setTitle:windowName];
    
    NSRect rect = NSMakeRect(0, 0, windowRect.size.width,windowRect.size.height-TITLEBAR_HEIGHT);
    [drawingView setFrame:rect];
    
    //[drawingView setRowData: bytes + theRow*bytesPerRow*pixPerPt];
    NSData* colData = [[NSData alloc] initWithBytes:colbytes length:(int)dataRect.size.height*pixPerPt*4];
    [drawingView setColData: colData];
    [drawingView setBytesPerRow: (int)dataRect.size.height*pixPerPt*4];
    [drawingView setPixPerPt: pixPerPt];
    
    [drawingView display];
    delete colbytes;
    [[dataWindowController imageView] setEraseLines:0];
    [[dataWindowController imageView] display];
    
}

-(void) updateColDrawing: (int) theCol {
    // where the data comes from
    NSRect dataRect =  [[dataWindowController imageView] frame ];
    
    [[dataWindowController imageView] setEraseLines:1];
    [[dataWindowController imageView] display];
    
    // get the bitmap from the data window
    [[dataWindowController imageView] lockFocus];
    NSBitmapImageRep* imageRep=[[NSBitmapImageRep alloc] initWithFocusedViewRect: dataRect] ;
    unsigned char* bytes = [imageRep bitmapData];
    int bytesPerRow = (int)[imageRep bytesPerRow];
    int pixPerPt = bytesPerRow/4/[[dataWindowController imageView] frame ].size.width;
    // = 2 for retina displays
    unsigned char* colbytes = new unsigned char[(int)dataRect.size.height*pixPerPt*4];
    int n=0;
    for(int i=0; i < (int)dataRect.size.height*pixPerPt; i++){
        for(int j=0; j < 4; j++){
            colbytes[n++] = *(bytes+i*bytesPerRow+theCol*4*pixPerPt+j);
        }
    }
    [[dataWindowController imageView] unlockFocus];
    
    //[drawingView setRowData: bytes + theRow*bytesPerRow*pixPerPt];
    NSData* colData = [[NSData alloc] initWithBytes:colbytes length:(int)dataRect.size.height*pixPerPt*4];

    [drawingView setColData: colData];
    [drawingView setBytesPerRow: (int)dataRect.size.height*pixPerPt*4];
    
    [drawingView display];
    [[dataWindowController imageView] setEraseLines:0];
    [[dataWindowController imageView] display];
    delete colbytes;
}


-(BOOL) acceptsFirstResponder{
    return YES;
}

- (void)keyDown:(NSEvent *)anEvent{
    [[appController theWindow] sendEvent: anEvent];
}


- (IBAction)copy:sender {
    // need things here to copy line drawings
    // also can add same to data window

    NSView *view = [self drawingView];
    NSRect r = [view bounds];
    
    if (view != nil) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [view writePDFInsideRect:r toPasteboard: pasteboard];
    }
    
}


@end
