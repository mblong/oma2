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
/*{
    NSString    *windowName;
    DataView    *__weak imageView;
    int         hasRowPlot;
    int         hasColPlot;
    int         thePalette;
}
*/
@property (copy) NSString *windowName;
@property __strong IBOutlet DataView *imageView;
@property NSRect windowRect;
@property int         hasRowPlot;
@property int         hasColPlot;
@property int thePalette;

-(void) placeImage: (NSRect) theRect;
-(void) placeRowLine: (int) theRow;
-(void) placeColLine: (int) theCol;
-(void) updateImage;

@end
