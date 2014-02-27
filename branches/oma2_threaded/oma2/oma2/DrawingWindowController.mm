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
    // NSLog(@"deallocate DataWindowController");
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
    //extern RGBColor color[256][8];
    drawingType = ROW_DRAWING;
    
    [[dataWindowController imageView] setEraseLines:1];
    [[dataWindowController imageView] display];

    // where the data comes from
    NSRect dataRect =  [[dataWindowController imageView] frame ];
    
    // change the dataRect to be a single row
    int theWindowRow = dataRect.size.height/2;       // start in the middle

    int pal = [dataWindowController thePalette];
    unsigned char* bytes = [dataWindowController intensity];    // the start of the data
    // find the pointer to the specific row
    int bytesPerRow;
    //float widthScale = iBitmap.getwidth()/dataRect.size.width;
    float theheightScale = (float)[dataWindowController dataRows]/(float)dataRect.size.height;
    
    int theRow = theWindowRow * theheightScale;

    if(pal >= 0) { // we have a monochrome image
        bytes += theRow * [dataWindowController dataCols];
        bytesPerRow = [dataWindowController dataCols];
        [drawingView setIsColor:0];
    } else {
        bytes += theRow * [dataWindowController dataCols]*3;
        bytesPerRow = [dataWindowController dataCols]*3;
        [drawingView setIsColor:1];
    }
    NSData* rowData = [[NSData alloc] initWithBytes:bytes length: bytesPerRow ];
    
    // at this point, bytes points to the row of data and rowData has the data
    
    [dataWindowController setHasRowPlot:theWindowRow];
    [dataWindowController placeRowLine:theWindowRow]; 
    [[dataWindowController imageView] setRowWindowController:self];

    windowRect = theLocation;
    [[self window] setTitle:windowName];
    
    NSRect rect = NSMakeRect(0, 0, windowRect.size.width,windowRect.size.height-TITLEBAR_HEIGHT);
    [drawingView setFrame:rect];
    
    //[drawingView setRowData: bytes + theRow*bytesPerRow*pixPerPt];
    [drawingView setRowData: rowData];
    [drawingView setBytesPerRow: bytesPerRow];
    //[drawingView setPixPerPt: bytesPerRow/4/[[dataWindowController imageView] frame ].size.width];
    [drawingView setPixPerPt: 1];
    [drawingView setHeightScale:theheightScale];
    [drawingView setTheRow: theWindowRow ];
    [drawingView display];
    [[dataWindowController imageView] setEraseLines:0];
    [[dataWindowController imageView] display];

}

-(void) updateRowDrawing: (int) theWindowRow {
    // where the data comes from
    NSRect dataRect =  [[dataWindowController imageView] frame ];
    // change the dataRect to be a single row
    //dataRect.origin.y = dataRect.size.height - theRow-1;
    //dataRect.size.height = 1;
    
    [[dataWindowController imageView] setEraseLines:1];
    [[dataWindowController imageView] display];

    int pal = [dataWindowController thePalette];
    unsigned char* bytes = [dataWindowController intensity];    // the start of the data
    // find the pointer to the specific row
    float heightScale = (float)[dataWindowController dataRows]/dataRect.size.height;
    //x *= widthScale;
    int theRow = theWindowRow * heightScale;

    int bytesPerRow;
    if(pal >= 0) { // we have a monochrome image
        bytes += theRow * [dataWindowController dataCols];
        bytesPerRow = [dataWindowController dataCols];
        [drawingView setIsColor:0];
    } else {
        bytes += theRow * [dataWindowController dataCols]*3;
        bytesPerRow = [dataWindowController dataCols]*3;
        [drawingView setIsColor:1];
    }
    NSData* rowData = [[NSData alloc] initWithBytes:bytes length: bytesPerRow ];

    
    //[drawingView setRowData: bytes + theRow*bytesPerRow*pixPerPt];
    [drawingView setRowData: rowData];
    [drawingView setBytesPerRow: bytesPerRow];
    [drawingView setTheRow: theWindowRow ];
    
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
    int theWindowCol = dataRect.size.width/2;       // start in the middle
    
    int pal = [dataWindowController thePalette];
    unsigned char* bytes = [dataWindowController intensity];    // the start of the data
    // find the pointer to the specific row
    int bytesPerRow;
    float widthScale = [dataWindowController dataCols]/dataRect.size.width;
    //float theheightScale = (float)[dataWindowController dataRows]/(float)dataRect.size.height;
    
    int theCol = theWindowCol * widthScale;
    int bytesPerPix;
    unsigned char* colbytes;
    if(pal >= 0) { // we have a monochrome image
        colbytes = new unsigned char[[dataWindowController dataRows]];
        //bytes += theCol * [dataWindowController dataCols];
        bytesPerRow = [dataWindowController dataCols];
        [drawingView setIsColor:0];
        bytesPerPix = 1;
    } else {
        colbytes = new unsigned char[[dataWindowController dataRows]*3];
        //bytes += theCol * [dataWindowController dataCols]*3;
        bytesPerRow = [dataWindowController dataCols]*3;
        [drawingView setIsColor:1];
        bytesPerPix = 3;
    }
    int n=0;
    for(int i=0; i < [dataWindowController dataRows]; i++){
        for(int j=0; j < bytesPerPix; j++){
            colbytes[n++] = *(bytes+theCol*bytesPerPix+i*bytesPerRow+j);
        }
    }

    [dataWindowController setHasColPlot:theWindowCol];
    [dataWindowController placeColLine:theWindowCol];
    [[dataWindowController imageView] setColWindowController:self];
    
    windowRect = theLocation;
    [[self window] setTitle:windowName];
    
    NSRect rect = NSMakeRect(0, 0, windowRect.size.width,windowRect.size.height-TITLEBAR_HEIGHT);
    [drawingView setFrame:rect];
    
    //[drawingView setRowData: bytes + theRow*bytesPerRow*pixPerPt];
    NSData* colData = [[NSData alloc] initWithBytes:colbytes length:[dataWindowController dataRows]*bytesPerPix];
    [drawingView setColData: colData];
    [drawingView setBytesPerRow: [dataWindowController dataRows]*bytesPerPix];
    [drawingView setPixPerPt: 1];
    [drawingView setWidthScale:widthScale];
    [drawingView setTheCol: theWindowCol ];
    [drawingView display];
    delete colbytes;
    [[dataWindowController imageView] setEraseLines:0];
    [[dataWindowController imageView] display];
}

-(void) updateColDrawing: (int) theWindowCol {
    // where the data comes from
    NSRect dataRect =  [[dataWindowController imageView] frame ];
    
    [[dataWindowController imageView] setEraseLines:1];
    [[dataWindowController imageView] display];
    
    int pal = [dataWindowController thePalette];
    unsigned char* bytes = [dataWindowController intensity];    // the start of the data
    // find the pointer to the specific row
    int bytesPerRow;
    float widthScale = [dataWindowController dataCols]/dataRect.size.width;
    
    int theCol = theWindowCol * widthScale;
    int bytesPerPix;
    unsigned char* colbytes;
    if(pal >= 0) { // we have a monochrome image
        colbytes = new unsigned char[[dataWindowController dataRows]];
        //bytes += theCol * [dataWindowController dataCols];
        bytesPerRow = [dataWindowController dataCols];
        [drawingView setIsColor:0];
        bytesPerPix = 1;
    } else {
        colbytes = new unsigned char[[dataWindowController dataRows]*3];
        //bytes += theCol * [dataWindowController dataCols]*3;
        bytesPerRow = [dataWindowController dataCols]*3;
        [drawingView setIsColor:1];
        bytesPerPix = 3;
    }
    int n=0;
    for(int i=0; i < [dataWindowController dataRows]; i++){
        for(int j=0; j < bytesPerPix; j++){
            colbytes[n++] = *(bytes+theCol*bytesPerPix+i*bytesPerRow+j);
        }
    }
    NSData* colData = [[NSData alloc] initWithBytes:colbytes length:[dataWindowController dataRows]*bytesPerPix];
    [drawingView setColData: colData];
    [drawingView setBytesPerRow: [dataWindowController dataRows]*bytesPerPix];
    [drawingView setTheCol: theWindowCol ];
    [dataWindowController placeColLine:theWindowCol];
    
    [drawingView display];
    [[dataWindowController imageView] setEraseLines:0];
    [[dataWindowController imageView] display];
    delete colbytes;
}


-(BOOL) acceptsFirstResponder{
    return NO;
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
