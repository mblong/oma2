//
//  DrawingWindowController.h
//  oma2
//
//  Created by Marshall Long on 10/6/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DrawingView;
@class DataWindowController;

enum {ROW_DRAWING,COL_DRAWING,LINE_PLOT_DRAWING};

@interface DrawingWindowController : NSWindowController
/*{
    NSString    *windowName;
    DrawingView    *__weak drawingView;
    DataWindowController *dataWindowController;
    int drawingType;
    

}
*/
//@property (assign) IBOutlet NSWindow *window;

@property (copy) NSString *windowName;
@property __weak IBOutlet DrawingView *drawingView;
@property NSRect windowRect;
@property DataWindowController *dataWindowController;
@property int drawingType;

-(void) placeRowDrawing: (NSRect) theLocation;
-(void) updateRowDrawing: (int) theRow;
-(void) placeColDrawing: (NSRect) theLocation;
-(void) placeLinePlotDrawing: (NSRect) theLocation WithStart: (NSPoint) start AndEnd: (NSPoint) end;
-(void) updateColDrawing: (int) theCol;

@end
