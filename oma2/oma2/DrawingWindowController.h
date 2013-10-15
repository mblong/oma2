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

enum {ROW_DRAWING,COL_DRAWING};

@interface DrawingWindowController : NSWindowController{
    NSString    *windowName;
    DrawingView    *__weak drawingView;
    DataWindowController *dataWindowController;
    int drawingType;
    

}

@property (copy) NSString *windowName;
@property (weak) IBOutlet DrawingView *drawingView;
@property NSRect windowRect;
@property DataWindowController *dataWindowController;
@property int drawingType;

-(void) placeRowDrawing: (NSRect) theLocation;
-(void) updateRowDrawing: (int) theRow;
-(void) placeColDrawing: (NSRect) theLocation;
-(void) updateColDrawing: (int) theCol;

@end
