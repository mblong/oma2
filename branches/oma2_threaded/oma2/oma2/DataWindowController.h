//
//  DataWindowController.h
//  oma2
//
//  Created by Marshall Long on 3/29/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define CLOSE_CLEANUP_DONE -10

@class DataView;

@interface DataWindowController : NSWindowController
{
    NSString    *windowName;
    DataView    *__weak imageView;
    int         hasRowPlot;
    int         hasColPlot;
    int         thePalette;
    unsigned char*   intensity;
    int         intensitySize;
    int         dataRows;
    int         dataCols;
}

@property (copy) NSString *windowName;
@property __weak IBOutlet DataView *imageView;      // what's the difference between weak and strong here?
@property NSRect windowRect;
@property int    hasRowPlot;
@property int    hasColPlot;
@property int    thePalette;
@property unsigned char*   intensity;
@property int    dataRows;
@property int    dataCols;

-(void) placeImage: (NSRect) theRect;
-(void) placeRowLine: (int) theRow;
-(void) placeColLine: (int) theCol;
-(void) updateImage;

@end
