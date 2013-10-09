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

@interface DrawingWindowController : NSWindowController{
    NSString    *windowName;
    DrawingView    *__weak drawingView;
    DataWindowController *dataWindowController;
    

}

@property (copy) NSString *windowName;
@property (weak) IBOutlet DrawingView *drawingView;
@property NSRect windowRect;
@property DataWindowController *dataWindowController;

//-(void) placeDrawing: (NSRect) theRect;
-(void) placeDrawing: (NSRect) theLocation;
@end
